# NOTE: pkgs.caprine is dead upstream — Meta retired messenger.com 04/2026
# (redirect to facebook.com/messages); use the active fork bankjaneo/caprine.
# Bump `version` below, then `nix run .#write-flake && nix flake update caprine`
# — the lock records the asset's hash itself, nothing to paste.
{inputs, ...}: let
  version = "2.63.5";
in {
  flake-file.inputs.caprine = {
    url = "https://github.com/bankjaneo/caprine/releases/download/v${version}/Caprine-${version}-x86_64.AppImage";
    flake = false;
  };
  core.gui.caprine.homeManager = {pkgs, ...}: {
    home.packages = [
      (pkgs.appimageTools.wrapType2 (finalAttrs: {
        pname = "caprine";
        inherit version;
        src = inputs.caprine;

        nativeBuildInputs = [pkgs.makeWrapper];

        extraInstallCommands = ''
          wrapProgram $out/bin/caprine --add-flags --ozone-platform-hint=auto

          install -m 444 -D ${finalAttrs.contents}/caprine.desktop -t $out/share/applications
          substituteInPlace $out/share/applications/caprine.desktop \
            --replace-fail 'Exec=AppRun' 'Exec=caprine'
          cp -r ${finalAttrs.contents}/usr/share/icons $out/share
        '';
      }))
    ];
  };
}
