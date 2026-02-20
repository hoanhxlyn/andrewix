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
        users.${name}.userName = {inherit userName;};
      };
      andrew-pc = {
        hostName = "andrew-pc";
        description = "Personal pc";
        users.${name} = {inherit userName;};
      };
    };

    # homes.${arch}.${name} = {
    #   inherit userName;
    # };

    aspects = {
      # ${name}.includes = [<my/user>];
      andrew-laptop.includes = [<my/devices/home-laptop>];
      andrew-pc.includes = [<my/devices/home-pc>];
    };
  };
}
