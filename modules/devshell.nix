{
  inputs,
  ...
}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    formatter = pkgs.alejandra;

    packages = {
      inherit (inputs.fcitx5-vmk-nix.packages.${pkgs.system}) fcitx5-vmk;
    };

    devShells.default = pkgs.mkShell {
      packages = with pkgs;
        [
          git
          neovim
        ]
        ++ [pkgs.pre-commit];
      shellHook = ''
        ${config.pre-commit.installationScript}
      '';
    };
  };
}
