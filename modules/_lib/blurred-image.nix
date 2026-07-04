{
  pkgs,
  image,
}:
pkgs.runCommand "blurred-background" {
  buildInputs = [pkgs.imagemagick];
} ''
  convert ${image} -blur 0x25 $out
''
