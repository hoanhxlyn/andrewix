{
  lib,
  fetchurl,
  appimageTools,
  symlinkJoin,
  makeWrapper,
  makeDesktopItem,
  wayland,
}: let
  pname = "pomotroid";
  version = "1.7.1";
  src = fetchurl {
    url = "https://github.com/Splode/pomotroid/releases/download/v${version}/Pomotroid_${version}_amd64.AppImage";
    sha256 = "0ri2fq2fwjms6fjq16hyaj86xcwxxkdqjijjvsspww79m9jrrld7";
  };

  unwrapped = appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs:
      with pkgs; [
        icu
        libxcrypt-legacy
      ];

    meta = {
      description = "Simple and configurable Pomodoro timer";
      homepage = "https://github.com/Splode/pomotroid";
      license = lib.licenses.mit;
      mainProgram = "pomotroid";
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  };

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Pomotroid";
    comment = "Simple and configurable Pomodoro timer";
    exec = "${pname}";
    icon = "clock";
    categories = ["Office"];
  };
in
  symlinkJoin {
    name = "${pname}-${version}";
    paths = [unwrapped desktopItem];
    buildInputs = [makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/${pname} \
        --set LD_PRELOAD "${wayland}/lib/libwayland-client.so.0"
    '';
    inherit (unwrapped) meta;
  }
