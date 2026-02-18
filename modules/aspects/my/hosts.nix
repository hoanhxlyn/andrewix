{
  __findFile ? __findFile,
  den,
  inputs,
  ...
}: let
  users = {
    andrew = {
      description = "Andrew Nguyen";
      shell = "fish";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };
in {
  den.hosts.x86_64-linux.andrew-pc = {
    inherit users;
    specialModules = [
      inputs.aic8800.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];
  };

  den.hosts.x86_64-linux.andrew-laptop = {
    inherit users;
    specialModules = [
      inputs.aic8800.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];
  };

  den.homes.x86_64-linux.andrew = {};

  den.aspects.andrew-pc.includes = [
    <andrewix/common>
    <andrewix/system/hostname/andrew-pc>
    <andrewix/system/hardware/andrew-pc>
    (<andrewix/system/gpu/nvidia>)
    <andrewix/system/gaming/xone>
    <andrewix/system/gaming/steam>
    (<andrewix/system/terminal> {whichOne = "alacritty";})
  ];

  den.aspects.andrew-laptop.includes = [
    <andrewix/common>
    <andrewix/system/hostname/andrew-laptop>
    <andrewix/system/hardware/andrew-laptop>
    (<andrewix/system/terminal> {whichOne = "wezterm";})
  ];

  den.aspects.andrew.includes = [
    <den/primary-user>
    <andrewix/user/development>
    <andrewix/user/desktop>
    <andrewix/user/utilities>
  ];

  den.default.includes = [
    <my/state-version>
  ];
}
