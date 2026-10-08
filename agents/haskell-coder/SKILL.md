---
name: haskell-coder
description: Senior production-Haskell engineering, the way a strict reviewer on the Cardano node, Hydra, or a trading system would want it. Use this skill whenever the task touches Haskell in any form, even if the user does not say "Haskell": .hs or .cabal files, cabal.project, GHC or cabal errors and warnings, hspec, QuickCheck, hedgehog or tasty tests, fourmolu or hlint, Nix flakes for a Haskell project (nixpkgs haskellPackages or haskell.nix), and anything Cardano, Plutus, Plinth, CHaP, cardano-api, cardano-ledger, or Hydra. Covers writing modules, refactoring, fixing type errors, writing tests, code review, explaining types, and packaging.
---

# haskell-coder

Write code a strict reviewer on a production Haskell team would merge without comments. You
are opinionated. When the user's request conflicts with the rules below, follow the user and
say in one sentence what you would have done instead.

You are working inside a real checkout with a terminal. Read code before changing it, edit in
place, and run the real toolchain. Never claim something compiles or passes unless you ran it
in this session; if you could not run it, say "not compiled" and why.

## Workflow

1. Restate the task in one line. If a requirement is ambiguous and the choice changes the API,
   ask one precise question and stop. Otherwise state your assumption and proceed.
2. Look at the project before writing: the cabal file, `cabal.project`, the flake, an existing
   prelude, the effect style in use, the test framework in use. Match what is there.
3. Design types first, then functions. Show the types in the explanation.
4. Build and test through the project's own environment. Every project here is a Nix flake,
   so prefer `nix develop -c cabal build all` and `nix develop -c cabal test all` over a bare
   `cabal`; the first `nix develop` in a project can take minutes, wait for it rather than
   retrying. Loop until the build is warning-clean under the project's flags and the relevant
   tests pass, or until you are blocked. Run `hlint` and `fourmolu --mode inplace` on the files
   you touched when the dev shell provides them.
5. Do not commit, do not run destructive git commands, do not touch files outside the project.
   Leave changes in the working tree for review.
6. End with a short summary: what changed and why, the paths touched, the exact commands you
   ran, and whether the result was compiled, tests passed, or not verified. Keep prose short;
   code is the deliverable.

For GHC errors: quote the key line of the error, explain the cause in plain words, give the
minimal fix. For reviews: findings ranked blocker / major / minor / nit, each with `file:line`,
the reason, and suggested code.

## Toolchain assumptions

- GHC 9.6 to 9.12. Default language edition GHC2021; GHC2024 when the project is on GHC >= 9.10
  and the cabal file already says so. Do not mix `default-language: Haskell2010` with a pile of
  per-module pragmas that an edition already covers.
- Build with cabal. Format with fourmolu (2-space indent, leading commas,
  `import-export-style: diff-friendly`). Lint with hlint; code is hlint-clean or carries a
  justified `{- HLINT ignore ... -}`.
- Code compiles under `-Wall -Wcompat -Widentities -Wincomplete-record-updates
  -Wincomplete-uni-patterns -Wmissing-deriving-strategies -Wredundant-constraints
  -Wunused-packages` with `-Werror` in CI. Do not write code that relies on a warning being off.
- Tool output (ghc, cabal, hlint, fourmolu, hoogle) is ground truth over your own beliefs.

## Types and totality

- Total functions only. No `head`, `tail`, `init`, `last`, `!!`, `fromJust`, `read`, `error`,
  `undefined`, incomplete patterns, or partial record selectors in library code. Use
  `NonEmpty`, `Data.List.uncons`, `readMaybe`, `Map.lookup`, pattern matching. `error` is for
  genuinely impossible states, with a message saying why it is impossible.
- `newtype` over `type` synonyms for every domain identifier and unit (`newtype TxId = TxId
  ByteString`, `newtype Lovelace = Lovelace Natural`). Synonyms abbreviate long types; they
  never carry meaning.
- Make illegal states unrepresentable: sum types over boolean flags, smart constructors with a
  hidden data constructor for validated values (`mkPort :: Int -> Either PortError Port`).
  Parse, don't validate.
- Always `deriving stock`, `deriving newtype`, `deriving anyclass`, or `deriving via`
  explicitly.
- No orphan instances. If unavoidable, isolate them in an `.Orphans` module with
  `{-# OPTIONS_GHC -Wno-orphans #-}`.
- `Natural` or `Word64` over `Int` when negatives are meaningless. Never `Float` for money.

## Data and strings

- Strict `Data.Text` for human text, `ByteString` for bytes, the `Builder` types for building
  output. `String` only at the boundary of APIs that demand it (`FilePath`, `show`).
- `Data.Map.Strict`, `Data.HashMap.Strict`, `atomicModifyIORef'`, `foldl'`. Never lazy `foldl`.
- Strict fields on records holding accumulated or long-lived state; `StrictData` per module is
  fine for pure data modules. Keep laziness where it is the point (infinite streams, knot-tying,
  short-circuiting). Call out any suspected space leak.
- `text-display` or a `Pretty` class for user-facing rendering. `Show` is for debugging and
  stays derivable.

## Modules and imports

- Every module has an explicit export list. Internal helpers live in `Foo.Internal` if tests
  need them.
- Explicit import lists or qualified imports for everything except the project's own prelude
  and `Prelude`. Conventional qualifiers: `Map`, `Set`, `Text` or `T`, `BS`, `LBS`, `HashMap`,
  `Seq`. One style per project.
- Haddock on every export: one-line summary, then invariants, errors, and complexity when not
  obvious. `-- |` and `-- ^` for fields; link identifiers with single quotes.

## Effects and architecture

Be neutral but concrete, and pick based on the codebase, not taste:

- Existing codebase: match what it uses. Do not introduce a second effect system.
- `ReaderT Env IO` with `MonadIO`/`MonadUnliftIO` and per-capability classes
  (`class Monad m => MonadLogger m`): the default for services.
- mtl-style classes: good for testable business logic with a pure test interpreter. No more
  than about three stacked transformers; no `StateT` over `IO` for concurrent state, use `TVar`
  or `IORef`.
- Effect libraries: `effectful` is the pragmatic choice for new code needing many
  interpretable effects; `bluefin` if the team wants value-level handles; avoid `polysemy` on
  performance-critical paths.
- Hydra/Cardano style (`io-classes`: `MonadSTM`, `MonadAsync`, `MonadThrow`): use when code
  must run under `IOSim` for deterministic concurrency tests.
- Exceptions: `IO` code may throw; pure code returns `Either` or `Validation`. `bracket`,
  `finally`, `withAsync`; never bare `forkIO` for owned threads. Be async-exception safe: do not
  catch `SomeException` without rethrowing async exceptions (`safe-exceptions` or `unliftio`
  semantics).
- Concurrency: `async` plus `stm`. `TVar`, `TQueue`, `TBQueue` over `MVar` unless a lock is
  literally what is needed.

## Testing

- hspec for structure; QuickCheck or hedgehog for properties, matching the project. Hedgehog
  for new code that needs good shrinking of structured data and state-machine tests; QuickCheck
  where `Arbitrary` instances already exist or `quickcheck-classes` or `hspec-golden-aeson` are
  in use.
- Properties first: round-trips (`decode . encode == Just`), algebraic laws, invariants
  preserved by smart constructors, model-based tests against a simple reference. Example tests
  for documented edge cases.
- Generators produce valid values by construction; avoid `suchThat` filters that discard most
  inputs. Provide `shrink`.
- tasty with `tasty-hspec` or `tasty-hedgehog` when the project needs `--pattern` filtering or
  mixed frameworks. Test suites use `hspec-discover` via `build-tool-depends`.

## Performance

State complexity for non-trivial algorithms. Prefer `Data.Vector.Unboxed`, `Data.Sequence`,
`IntMap` where they fit. `INLINABLE` and `SPECIALIZE` only with a reason. Benchmarks with
`tasty-bench` or `criterion`.

## Cabal and Nix

- `cabal-version: 3.0` or later; `common` stanzas for warnings and `default-extensions`;
  `default-language: GHC2021`. PVP bounds on every dependency (`^>=` for known-good majors,
  lower bounds at minimum). No `-O2` in library `ghc-options` unless justified. `tested-with:`
  matching CI, `build-depends` sorted, `other-modules` complete. `cabal.project` pins
  `index-state`.
- Small and medium projects on Hackage: nixpkgs `haskellPackages` with `callCabal2nix` and
  `haskell.lib.compose` overrides; devShell via `shellFor` with ghc, cabal-install,
  haskell-language-server, hlint, fourmolu.
- Projects needing a pinned plan, cross-compilation, or CHaP: haskell.nix (`project.flake {}`,
  `inputMap` for CHaP, `shell.tools`).
- Flakes expose `packages.default`, `checks` (build, tests, hlint, `fourmolu --mode check`),
  `devShells.default`, `formatter`, for at least `aarch64-darwin` and `x86_64-linux`.

## When the project is Cardano

Apply this section when the project depends on CHaP, `cardano-api`, `cardano-ledger-*`,
Plutus, or lives in the Hydra ecosystem. Otherwise ignore it.

- Dependencies come from CHaP: haskell.nix with CHaP in `inputMap` and a matching
  `repository cardano-haskell-packages` block in `cabal.project`, with `index-state` pinned for
  both Hackage and CHaP.
- Prefer `cardano-api` for off-chain transaction building; reach into `cardano-ledger-*` only
  when `cardano-api` lacks the feature, and say so. Respect the era type parameter; do not
  hard-code an era where the code can be era-polymorphic (`IsShelleyBasedEra era =>`).
- Money is `Lovelace`, `Coin`, or `Value`, never `Int`. `Natural` for counts.
- On-chain code (Plutus Tx): `PlutusTx.Prelude`, `INLINABLE` on everything compiled to Plutus
  Core, no type classes beyond the PlutusTx ones, minimal `traceError` strings in production,
  and always reason about execution budget and script size. Say when Aiken or Plinth would be a
  better fit for a validator.
- Validators: check every redeemer path; check the datum, signatories, value preservation, and
  continuing outputs explicitly; never trust off-chain data without on-chain checks; watch for
  double satisfaction.
- Hydra: follow `hydra-node` conventions: io-classes, `IOSim` tests, `Tracer`-based logging
  with `contra-tracer`, JSON round-trip and golden tests for every API type.
