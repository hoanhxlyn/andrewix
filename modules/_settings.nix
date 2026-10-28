# Shared host settings (DE-style sections). Per-host overrides go through mkHost; hardware facts
# live in host-facts.nix.
{
  terminal.padding = 2;
  terminal.mux = "herdr";
  locale.lang = "en_US.UTF-8";
  # numbers, money, paper, address, name, phone, measurement, identification
  # vi_VN (no .UTF-8): glibc's SUPPORTED has `vi_VN/UTF-8`, and NixOS appends the charset.
  locale.formats = "vi_VN";
  locale.time = "en_US.UTF-8";
  # Default applications
  defaults.browser = "zen";
  defaults.terminal = "kitty";
  defaults.shell = "fish";
  # Per-user data, exposed to aspects as `user.<key>`; typed in modules/schema.nix.
  profiles.andrew.displayName = "Andrew Nguyen";
  profiles.andrew.git.name = "Andrew Nguyen";
  profiles.andrew.git.email = "hoanhxlyn@gmail.com";
  login = "ly";
  # WSL only: where Windows lives as seen from the distro. mkHost derives `host.windows.*` paths.
  windows.mountRoot = "/mnt"; # wsl.conf automount root
  windows.drive = "c";
  windows.tools.gitCredentialManager = "scoop/root/apps/git/current/mingw64/bin/git-credential-manager.exe";
  windows.tools.win32yank = "scoop/root/apps/win32yank/current/win32yank.exe";
  input.keyboard.layout = "us";
  input.keyboard.repeatDelay = 250; # ms before repeat starts
  input.keyboard.repeatRate = 50; # keys per second
  input.touchpad.tap = true;
  input.touchpad.naturalScroll = true;
  input.touchpad.disableWhileTyping = true;
  input.mouse.accelProfile = "flat"; # flat | adaptive
  accessibility.cursorSize = 24;
  accessibility.hideCursorWhenTyping = true;
  accessibility.animations.enable = true;
  accessibility.animations.slowdown = 1.5; # >1 = slower
  # Look & feel (pure data; packages stay in modules/core/services/sync/stylix.nix).
  appearance = {
    scheme = "tokyodark"; # base16-schemes name
    polarity = "dark"; # light | dark
    font = {
      size = 12; # pt; terminal/applications/desktop derive from it
      # pkg = attribute path into pkgs (resolved in stylix.nix); name = family the pkg provides.
      mono.pkg = "nerd-fonts.caskaydia-cove";
      mono.name = "CaskaydiaCove Nerd Font";
      sans.pkg = "noto-fonts";
      sans.name = "Noto Sans";
      emoji.pkg = "noto-fonts-color-emoji";
      emoji.name = "Noto Color Emoji";
    };
    opacity = 0.8; # 1.0 = opaque; <1 enables blur/transparent bg
    # local (config/background/<path>) | gruvbox (AngelJumbo/gruvbox-wallpapers, <path> in repo)
    # | tokyonight (hoanhxlyn/tokyonight-wallpapers, <filename> in repo root)
    # | catppuccin (orangci/walls-catppuccin-mocha, <filename> in repo root)
    # | remote ({url, hash} instead of path)
    wallpaper.source = "tokyonight";
    wallpaper.path = "neon-city.png";
    wallpaper.scaling = "center"; # fill | center | stretch | fit
    toast = {
      width = 400;
      border.radius = 12;
      border.size = 2;
      layer = "top";
      position = "top-center";
      timeout = 3000;
      history = 10;
      offset.x = 0;
      # ×2 via terminal.padding = 40px: clears the 32px top waybar with an 8px gap.
      offset.y = 25;
      padding.x = 5;
      padding.y = 8;
    };
  };
}
