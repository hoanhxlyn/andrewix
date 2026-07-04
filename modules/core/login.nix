{
  # Login/display manager. Which greeter (if any) is chosen per device via the
  # `login` host param defined in modules/hosts.nix (e.g. login = "regreet").
  core.login = {host, ...}: {
    nixos = {
      pkgs,
      lib,
      config,
      ...
    }:
      lib.mkIf (host.login == "regreet") (let
        blurredBackground =
          pkgs.runCommand "regreet-blurred-background" {
            buildInputs = [pkgs.imagemagick];
          } ''
            convert ${config.stylix.image} -blur 0x25 $out
          '';

        # Wrap regreet with greeter-scoped env instead of overriding
        # services.greetd...default_session.command (which trips stylix's
        # "custom command may not work" warning). The regreet module builds that
        # command from `programs.regreet.package`, so wrapping the package keeps the
        # command string at stylix's expected default while still injecting env —
        # and stylix's theming (regreet.toml + css) applies regardless.
        #  - GSK_RENDERER=cairo: GTK4's ngl/vulkan renderer deadlocks on the username
        #    dropdown popup under cage on Intel; cairo is bulletproof for a login screen.
        #  - XCURSOR_*: regreet has no cursor-size option, so pin the GTK cursor to the
        #    desktop size/theme; wlroots' default otherwise renders huge.
        wrappedRegreet = pkgs.symlinkJoin {
          name = "regreet-wrapped";
          paths = [pkgs.regreet];
          nativeBuildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/regreet \
              --set GSK_RENDERER cairo \
              --set XCURSOR_THEME ${config.stylix.cursor.name} \
              --set XCURSOR_SIZE ${toString (host.terminal.fontSize * 2)}
          '';
          inherit (pkgs.regreet) version meta;
        };
      in {
        programs.regreet = {
          enable = true;
          package = wrappedRegreet;
          # Blur the stylix wallpaper (stylix sets the unblurred image by default).
          settings.background.path = lib.mkForce "${blurredBackground}";
        };
      });
  };
}
