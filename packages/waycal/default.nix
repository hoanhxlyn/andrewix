{
  lib,
  rustPlatform,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  gtk4-layer-shell,
}:
rustPlatform.buildRustPackage {
  pname = "waycal";
  version = "0.2.0-andrewix";

  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
  ];

  # Runtime deps `wl-copy` (wl-clipboard) and `notify-send` (libnotify) are not
  # bundled: waycal only ever runs inside the desktop session, which already has
  # both on PATH (essentials.nix + fuzzel.nix). wrapGAppsHook4 stays for GTK's
  # GSettings schemas / icon lookup.

  meta = {
    description = "Tiny Wayland calendar popup: keyboard day navigation, Enter copies the date (dd/mm/yyyy)";
    homepage = "https://github.com/ForrestKnight/waycal";
    license = lib.licenses.mit;
    mainProgram = "waycal";
    platforms = lib.platforms.linux;
  };
}
