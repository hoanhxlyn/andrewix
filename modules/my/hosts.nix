{__findFile ? __findFile, ...}: let
  arch = "x86_64-linux";
  name = "Andrew Nguyen";
  userName = "andrew";
in {
  den = {
    hosts.${arch} = {
      andrew-laptop = {
        hostName = "andrew-laptop";
        description = "Personal laptop";
        users.${name} = {inherit userName;};
      };
      andrew-pc = {
        hostName = "andrew-pc";
        description = "Personal pc";
        users.${name} = {inherit userName;};
      };
    };

    homes.${arch}.${name} = {
      inherit userName;
    };

    aspects = {
      andrew-laptop = {
        includes = [<my/devices/home-laptop>];
        user.description = name;
      };
      andrew-pc.includes = [<my/devices/home-pc>];

      # Standalone home-manager (for non-NixOS Linux)
      # ${name}.includes = [<my/devices/base>];
    };
  };
}
