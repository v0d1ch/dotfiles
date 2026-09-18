# Ollama built against the PrismML fork of llama.cpp, so it can run the
# Ternary Bonsai GGUFs from https://huggingface.co/prism-ml (tensor types
# PQ2_0 = 142 and PTQ1_0 = 143, Hadamard-rotated weights). Stock ollama
# rejects those files with `unsupported tensor "output.weight" size overflows`
# (ollama/ollama#18521) because upstream llama.cpp has no kernels for them yet.
#
# This reuses the nixpkgs `ollama` derivation and only swaps:
#   - the ollama source: v0.34.2 plus the patch in ./ollama-prism/, which
#     points the llama.cpp FetchContent pin at the fork, rebases ollama's
#     compat hook patch onto it and teaches fs/gguf the two Prism types;
#   - the pre-staged llama.cpp source: PrismML-Eng/llama.cpp, branch `prism`.
#
# Import a model with a Modelfile whose FROM is the downloaded *.gguf; see
# docs/ollama-bonsai.md. To bump: pick a newer prism-b* release tag from
# https://github.com/PrismML-Eng/llama.cpp/releases, update llamaCppRev and
# its hash, and re-check that the patch in ./ollama-prism/ still applies.
{ lib, stdenv, ollama, fetchFromGitHub, apple-sdk_15, apple-sdk_26 }:

let
  ollamaVersion = "0.34.2";

  # Tag prism-b10687-5d80cff (2026-09-17).
  llamaCppRev = "5d80cff0b8cb9f2bf823cfc4e71e3abb97f290d6";
  llamaCppSrc = fetchFromGitHub {
    owner = "PrismML-Eng";
    repo = "llama.cpp";
    rev = llamaCppRev;
    hash = "sha256-P/TrseqTkqQwD6wGgsznCl1P/bhZZT6e0K1+WBZXGLY=";
  };
in
ollama.overrideAttrs (finalAttrs: old: {
  pname = "ollama-prism";
  version = ollamaVersion;

  src = fetchFromGitHub {
    owner = "ollama";
    repo = "ollama";
    tag = "v${ollamaVersion}";
    hash = "sha256-Etp0hBtQvDwcsauGw2bz1d2r5GB9euOJ6MMgZJF5TXA=";
  };

  patches = (old.patches or [ ]) ++ [
    ./ollama-prism/0001-build-against-prismml-llama-cpp.patch
  ];

  # go.sum changes with the ollama version.
  vendorHash = "sha256-45FfI47tNHBPYOBLRrwuhADCUtkjAhlFrExlEy9piMI=";

  # 0.34 grew extra main packages (cmd/bench, mlx/generator) that would
  # otherwise land in bin/ next to ollama.
  subPackages = [ "." ];

  # nixpkgs builds ollama against the macOS 15 SDK. ggml's Metal backend then
  # fails its runtime "tensor API" probe (Metal 4, macOS 26) and falls back to
  # the older matmul path, which costs prompt-processing speed on M5-class GPUs.
  # Build against the 26 SDK instead; the binary still runs on older macOS.
  buildInputs = map (p: if p == apple-sdk_15 then apple-sdk_26 else p) (old.buildInputs or [ ]);

  postPatch = ''
    substituteInPlace version/version.go \
      --replace-fail 0.0.0 '${finalAttrs.version}'

    # CLI launcher integration tests need npm and the network; the desktop
    # app tree needs GUI toolkits. Neither builds in the sandbox.
    rm cmd/launch/*_test.go
    rm -r app

    # Pre-stage the fork for the FetchContent step and apply ollama's compat
    # hook patch to it. With FETCHCONTENT_SOURCE_DIR_LLAMA_CPP set, ollama's
    # own build skips that step (OLLAMA_LLAMA_CPP_SKIP_COMPAT_PATCH=ON), so
    # the caller has to. The applier is idempotent.
    cp -r ${llamaCppSrc} $TMPDIR/llama-cpp-src
    chmod -R +w $TMPDIR/llama-cpp-src
    ( cd $TMPDIR/llama-cpp-src && \
      cmake -DPATCH_DIR=$NIX_BUILD_TOP/source/llama/compat \
        -DPATCH_LABEL=llama/compat \
        -P $NIX_BUILD_TOP/source/cmake/apply-git-patches.cmake )
  '';

  # Upstream's Go test suite takes a long time and has network-touching
  # cases that need per-version skip lists; the fork is verified by loading
  # a Bonsai model instead.
  doCheck = false;

  passthru = old.passthru // {
    inherit llamaCppSrc llamaCppRev;
  };

  meta = old.meta // {
    description = "Ollama built on the PrismML llama.cpp fork (runs Ternary Bonsai PQ2_0/PTQ1_0 GGUFs)";
    homepage = "https://github.com/PrismML-Eng/llama.cpp";
    changelog = "https://github.com/ollama/ollama/releases/tag/v${ollamaVersion}";
  };
})
