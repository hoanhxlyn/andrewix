{
  andrew.editor.provides.vscode.nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.vscodium
    ];
  };
}
