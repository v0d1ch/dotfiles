# Upstream macOS release of Semantic Diff. Its Homebrew tap is invalid under
# Homebrew 7 because the formula has no URL for Linux validation targets.
{ stdenvNoCC, fetchurl, lib, git, makeWrapper }:

stdenvNoCC.mkDerivation rec {
  pname = "semantic-diff";
  version = "0.9.0";

  src = fetchurl {
    url = "https://github.com/alankyshum/semantic-diff/releases/download/v${version}/semantic-diff-v${version}-aarch64-apple-darwin.tar.gz";
    hash = "sha256-rfluDIcvTYsbu70QqgQtJToRBjRQp11t3CTqixGlAb0=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 semantic-diff $out/libexec/semantic-diff

    # v0.9.0 parses the output of `git diff` as a unified patch. The user's
    # default Git diff.external is Difftastic, so only this CLI's Git calls
    # need to opt out of external diff formatting.
    mkdir -p $out/libexec/git-bin
    cat > $out/libexec/git-bin/git <<EOF
    #!/bin/sh
    if [ "\$1" = diff ]; then
      shift
      exec ${git}/bin/git diff --no-ext-diff "\$@"
    fi
    exec ${git}/bin/git "\$@"
    EOF
    chmod +x $out/libexec/git-bin/git
    makeWrapper $out/libexec/semantic-diff $out/bin/semantic-diff \
      --prefix PATH : $out/libexec/git-bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "Diff viewer with semantic grouping for Git and GitHub PRs";
    homepage = "https://github.com/alankyshum/semantic-diff";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "semantic-diff";
  };
}
