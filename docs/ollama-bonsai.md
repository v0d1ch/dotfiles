# Ternary Bonsai in ollama (macbook)

The macbook's ollama is not the nixpkgs binary but `packages/ollama-prism.nix`:
ollama 0.34.2 rebuilt on the [PrismML fork of llama.cpp](https://github.com/PrismML-Eng/llama.cpp)
(branch `prism`). That is what lets it load the Ternary Bonsai model family from
[huggingface.co/prism-ml](https://huggingface.co/prism-ml), in particular
Ternary-Bonsai-2-27B at 5.9 GB, which stock ollama refuses with
`unsupported tensor "output.weight" size overflows` (ollama/ollama#18521).

## Why a fork

| Format   | ggml type | Who reads it                                   | Bonsai release                         |
|----------|-----------|------------------------------------------------|----------------------------------------|
| `Q1_0`   | 41        | upstream llama.cpp, stock ollama               | Bonsai (1-bit) 1.7B–27B                |
| `Q2_0` g64 | 42      | upstream llama.cpp; ollama once its pin catches up | Ternary-Bonsai 1.7B–27B (`*_g64.gguf`) |
| `PQ2_0`  | 142       | PrismML fork only                              | Ternary-Bonsai (`*-PQ2_0.gguf`), Bonsai 2 |
| `PTQ1_0` | 143       | PrismML fork only                              | Bonsai 2 27B (`*-PTQ1_0.gguf`, 5.9 GB) |

Bonsai 2 additionally stores its weights in a Hadamard-rotated basis and needs
the activation-side transform that only the fork implements; the metadata is
under `prism.hadamard.*` in the GGUF. Upstream tracking:
[ggml-org/llama.cpp#29058](https://github.com/ggml-org/llama.cpp/issues/29058).

Ollama itself does not vendor llama.cpp any more. It fetches the tag in
`LLAMA_CPP_VERSION` at build time, applies `llama/compat/001-llama-cpp-hooks.patch`
and builds `llama-server` from it. The fork therefore is small
(`packages/ollama-prism/0001-build-against-prismml-llama-cpp.patch`):

- `LLAMA_CPP_VERSION` and the two `GIT_REPOSITORY` lines point at
  `PrismML-Eng/llama.cpp` tag `prism-b10687-5d80cff`;
- the compat patch is rebased onto the fork (one hunk dropped: the fork has no
  `load_data_range` yet, so the hook for it has nowhere to go);
- `fs/gguf/tensor.go` and `fs/gguf/file_type.go` learn types 142/143 (block 128,
  34 and 28 bytes) and `general.file_type` 141/142/143, so `ollama create`
  can size the tensors.

The Nix side (`packages/ollama-prism.nix`) is `pkgs.ollama.overrideAttrs` with
the new source, that patch and the fork pre-staged where nixpkgs already
pre-stages upstream llama.cpp. `services.ollama.package` in
`darwin/configuration.nix` uses it; the home-manager module puts the same
package's CLI on PATH, so `modules/home.nix` ships stock `ollama` on Linux only.

## Importing a model

The models are plain GGUFs, imported with a Modelfile. Sampling parameters are
the ones the Prism demo uses.

```sh
# Bonsai 2 27B, 1.75 bpw, 5.9 GB on disk, ~7.4 GB resident at 16k context
curl -L -o ~/Downloads/Ternary-Bonsai-2-27B-PTQ1_0.gguf \
  https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf/resolve/main/Ternary-Bonsai-2-27B-PTQ1_0.gguf

cat > /tmp/Modelfile.bonsai2 <<EOF
FROM $HOME/Downloads/Ternary-Bonsai-2-27B-PTQ1_0.gguf
PARAMETER temperature 1.0
PARAMETER top_p 0.95
PARAMETER top_k 20
PARAMETER num_ctx 16384
EOF
ollama create bonsai2-27b -f /tmp/Modelfile.bonsai2
ollama run bonsai2-27b
```

`ollama create` copies the file into `~/.ollama/models`, so the download can be
deleted afterwards. `ollama show bonsai2-27b` should report `quantization PTQ1_0`
and the server log `loaded 402 Hadamard-folded weight(s)`.

Other files from the same family work the same way; `PQ2_0` variants of the
older Ternary-Bonsai 1.7B/4B/8B/27B are 6% smaller than the `_g64` ones and
have Metal kernels. The 27B models also ship an `mmproj` file for vision; the
ollama import ignores it (text only).

Measured on this M5 / 24 GB with the 27B PTQ1_0 file: 11–18 tok/s decode,
~90 tok/s prompt processing on a 940-token prompt, 100% GPU. The Prism demo
runs `llama-server` with `-fa on`; ollama leaves flash attention to its
default, so `OLLAMA_FLASH_ATTENTION=1` in `services.ollama.environmentVariables`
is the first thing to try for more speed.

The package builds against `apple-sdk_26` rather than nixpkgs' default 15 SDK.
Metal derives its default shading-language version from the SDK a binary was
linked with, and ggml's runtime probe for the Metal 4 tensor API (used for
matmuls on M5-class GPUs) fails under the 15 SDK: the server log then shows
`the tensor API is not supported in this environment - disabling` and prompt
processing drops to about a third.

## Updating

1. Pick a newer `prism-b*` tag from
   <https://github.com/PrismML-Eng/llama.cpp/releases>; set `llamaCppRev` and
   its hash in `packages/ollama-prism.nix` (`nix-prefetch-url --unpack` on the
   `archive/<rev>.tar.gz` URL, then `nix hash convert --hash-algo sha256 --to sri`).
2. Update the tag written into `LLAMA_CPP_VERSION` inside the patch.
3. Check `llama/compat/001-llama-cpp-hooks.patch` still applies to the new fork
   source; regenerate it if the fork moved (`git apply --reject`, fix, `git diff`).
4. Bumping the ollama base version means a new `src` hash and `vendorHash`
   (build once with `lib.fakeHash`, copy the reported hash).

The fork's own README warns not to mix its `ggml-*` libraries with a stock
build; ollama's darwin build links llama-server statically, so nothing leaks
between the two.

Once upstream llama.cpp gains the two types and ollama bumps its pin, this
package can go away: switch `services.ollama.package` back to `pkgs.ollama`
and move `ollama` back to the shared list in `modules/home.nix`.
