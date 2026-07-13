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

  extracted = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Pomotroid";
    comment = "Simple and configurable Pomodoro timer";
    exec = "pomotroid-launch";
    icon = "pomotroid";
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

      printf '#!/bin/sh\npgrep -x pomotroid >/dev/null 2>&1 && exit 0\nexec pomotroid "$@"\n' > "$out/bin/pomotroid-launch"
      chmod +x "$out/bin/pomotroid-launch"

        mkdir -p $out/share/icons
        cp -r ${extracted}/usr/share/icons/hicolor $out/share/icons/
    '';
    inherit (unwrapped) meta;
  }
