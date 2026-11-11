{
  lib,
  stdenv,
  fetchurl,
}: let
  version = "2.6.5";
in
  stdenv.mkDerivation {
    pname = "biome";
    inherit version;

    # NOTE: nixpkgs builds biome from source (fat LTO + cargo tests, ~1h, absent from
    # cache.nixos.org); bump version + hash by hand when `just update` moves nixpkgs.
    src = fetchurl {
      url = "https://github.com/biomejs/biome/releases/download/%40biomejs%2Fbiome%40${version}/biome-linux-x64-musl";
      hash = "sha256-Ai4e2kVIA7Ymw1z+Vgyy5d32WPPV5axdVGhjwFvcdu0=";
    };

    dontUnpack = true;
    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      install -Dm555 $src $out/bin/biome
    '';

    meta = {
      description = "Toolchain of the web (prebuilt static binary)";
      homepage = "https://biomejs.dev/";
      license = lib.licenses.mit;
      mainProgram = "biome";
      platforms = ["x86_64-linux"];
    };
  }
