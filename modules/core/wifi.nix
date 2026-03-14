{
  lib,
  inputs,
  ...
}: {
  flake-file.inputs.aic8800.url = lib.mkDefault "github:hoanhxlyn/aic8800-nix";
  core.wifi.nixos = {pkgs, ...}: {
    imports = [
      inputs.aic8800.nixosModules.default
    ];
    hardware.aic8800.enable = true;
    # Enable usb-modeswitch to handle ZeroCD (mass storage) mode
    hardware.usb-modeswitch.enable = true;
    # Ignore Tenda WiFi USB storage part to prevent automounting in udisks2 (GNOME)
    # and trigger usb-modeswitch to switch to WiFi mode
    services.udev.extraRules = let
      # Common IDs for Tenda/AIC/Realtek ZeroCD (Mass Storage) mode
      switchIds = [
        {
          vid = "a69c";
          pid = "5721";
        }
        {
          vid = "a69c";
          pid = "5723";
        }
        {
          vid = "a69c";
          pid = "5725";
        } # Matches current hardware
        {
          vid = "0bda";
          pid = "1a2b";
        }
      ];

      # IDs that should be ignored by file managers (udisks2)
      ignoreIds = [
        {
          vid = "a69c";
          pid = "5725";
        }
        {
          vid = "a69c";
          pid = "8d80";
        }
        {
          vid = "3020";
          pid = "0100";
        }
        {
          vid = "368b";
          pid = "*";
        }
        {
          vid = "0bda";
          pid = "a11b";
        }
        {
          vid = "0bda";
          pid = "8179";
        }
        {
          vid = "0bda";
          pid = "1a2b";
        }
      ];

      mkSwitchRule = d: ''ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="${d.vid}", ATTRS{idProduct}=="${d.pid}", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -KQ -v ${d.vid} -p ${d.pid}"'';

      mkIgnoreRule = d: ''ATTRS{idVendor}=="${d.vid}", ATTRS{idProduct}=="${d.pid}", ENV{UDISKS_IGNORE}="1"'';
    in ''
      # Force switch from Storage to WiFi mode
      ${lib.concatMapStringsSep "\n" mkSwitchRule switchIds}

      # Hide partitions from the File Manager
      ${lib.concatMapStringsSep "\n" mkIgnoreRule ignoreIds}
    '';
  };
}
