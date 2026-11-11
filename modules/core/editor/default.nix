{
  __findFile,
  self,
  ...
}: {
  core.editor.includes = [
    # <core.editor.nvf>
    <core.editor.nwm>
    # <core.editor.vscode>
    # <core.editor.cursor>
  ];

  core.editor.nixos.nixpkgs.overlays = [
    (final: _: {biome = final.callPackage "${self}/modules/core/editor/_lib/biome.nix" {};})
  ];
}
