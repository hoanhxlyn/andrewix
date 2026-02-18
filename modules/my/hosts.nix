{
  __findFile ? __findFile,
  inputs,
  ...
}: let
  arch = "x86_64-linux";
  username = "andrew";
in {
  den = {
    hosts.${arch} = {
      andrew-laptop = {
        description = "Personal laptop";
        users.${username} = {
          aspect = "laptop";
        };
      };
      # andrew-pc.users.${username} = {};
    };

    homes.${arch}.${username} = {
      aspect = "laptop";
      instantiate = {
        pkgs,
        modules,
      }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs modules;
          extraSpecialArgs.osConfig = inputs.self.nixosConfiguration.andrew-laptop.config;
        };
    };
    aspects = {
      ${username}.includes = [<my/user>];
      laptop.includes = [<my/workstation/hw>];
    };
  };
}
