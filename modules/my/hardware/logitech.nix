{
  den.aspects.my.hardware.logitech = {
    nixos = {
      hardware.logitech.wireless = {
        enable = true;
        enableGraphical = true;
      };
    };
    homeManager = {pkgs, ...}: let
      logitechBatteryScript = pkgs.writeShellScriptBin "waybar-logitech-battery" ''
        OUTPUT=$(${pkgs.solaar}/bin/solaar show 2>/dev/null) || exit 0
        [ -z "$OUTPUT" ] && exit 0

        BAT=$(echo "$OUTPUT" | ${pkgs.gnugrep}/bin/grep -oP 'Battery:\s+\K\d+' | ${pkgs.coreutils}/bin/sort -n | ${pkgs.coreutils}/bin/head -1)
        [ -z "$BAT" ] && exit 0

        printf '{"text":"🖱 %s%%","tooltip":"Logitech battery: %s%%"}' "$BAT" "$BAT"
      '';
    in {
      home.packages = [pkgs.solaar logitechBatteryScript];
      programs.waybar.settings.mainBar."custom/logitech-battery" = {
        exec = "${logitechBatteryScript}/bin/waybar-logitech-battery";
        return-type = "json";
        interval = 300;
        on-click = "solaar";
      };
    };
  };
}
