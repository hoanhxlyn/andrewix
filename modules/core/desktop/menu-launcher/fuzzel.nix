{
  lib,
  self,
  ...
}: {
  core.desktop.menu-launcher.fuzzel = {host, ...}: let
    inherit (host) terminal;
    isLaptop = host.isLaptop or false;
    msiEc = (host.chargeThreshold or {}).msiEc or false;
    # After a TLP profile switch, set the output mode to the throttled rate
    # (host.refreshThrottle). `performance` keeps the declared refresh-rate.
    # Only fires from this menu; a manual `sudo tlp <mode>` does not re-throttle.
    throttleRefresh = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        conn: rates: let
          mode = host.monitors.${conn}.mode;
          position = host.monitors.${conn}.position;
          setMode =
            if host.wm == "hyprland"
            then ''hyprctl keyword monitor "${conn},${toString mode.width}x${toString mode.height}@$_hz,${toString position.x}x${toString position.y},auto"''
            else "niri msg output ${conn} mode ${toString mode.width}x${toString mode.height}@$_hz";
        in ''
          case "$profile_cmd" in
            ${lib.optionalString (rates.balanced != null) "balanced) _hz=${toString rates.balanced} ;;"}
            ${lib.optionalString (rates.power-saver != null) "power-saver) _hz=${toString rates.power-saver} ;;"}
            *) _hz=${toString mode.refresh} ;;
          esac
          ${setMode} || true
        ''
      ) (host.refreshThrottle or {})
    );
  in {
    homeManager = {pkgs, ...}: {
      programs.fuzzel.enable = true;
      programs.fuzzel.settings.main = {
        terminal = "${host.defaults.terminal} -e";
        show-actions = true;
        width = 50;
        lines = 10;
        horizontal-pad = builtins.mul terminal.padding 2;
        inner-pad = builtins.mul terminal.padding 2;
        vertical-pad = builtins.mul terminal.padding 2;
        line-height = 30;
        image-size-ratio = 1.0;
        # icon-theme = "Papirus-Dark";
        scaling-filter = "lanczos3";
      };
      programs.fuzzel.settings.border.width = 1;
      programs.fuzzel.settings.border.radius = 15;

      home.file.".local/share/icons/hicolor/48x48/apps/yazi.png".source = "${pkgs.yazi}/share/pixmaps/yazi.png";

      # Utilities scripts
      home.packages =
        [
          pkgs.libnotify
          (pkgs.writeShellScriptBin "fuzzel-clipboard" (builtins.readFile "${self}/scripts/fuzzel/clipboard.sh"))

          (pkgs.writeShellScriptBin "fuzzel-audio" (builtins.readFile "${self}/scripts/fuzzel/audio.sh"))

          (pkgs.writeShellApplication {
            name = "fuzzel-notifications";
            runtimeInputs = with pkgs; [jq libnotify fuzzel mako];
            text = builtins.readFile "${self}/scripts/fuzzel/notifications.sh";
          })

          (pkgs.writeShellApplication {
            name = "fuzzel-emoji";
            runtimeInputs = with pkgs; [curl jq wl-clipboard libnotify fuzzel];
            text = builtins.readFile "${self}/scripts/fuzzel/emoji.sh";
          })

          (pkgs.writeShellScriptBin "fuzzel-font" ''
            selection=$(fc-list -f '%{family}\n' | sort -u | fuzzel --dmenu --prompt="Font: ")
            if [ -n "$selection" ]; then
              printf '%s' "$selection" | wl-copy
              notify-send "Font" "Copied $selection"
            fi
          '')

          (pkgs.writeShellScriptBin "fuzzel-power" ''
            dmenu_line() {
              printf '%s\0icon\x1f%s\n' "$1" "$2"
            }

            selection=$(
              {
                dmenu_line "Shutdown" "system-shutdown"
                dmenu_line "Reboot" "system-reboot"
                dmenu_line "Sleep" "system-suspend"
                dmenu_line "Logout" "system-log-out"
                dmenu_line "Lock" "system-lock-screen"
              } | fuzzel --dmenu --prompt="System: "
            )
            case "$selection" in
              *Shutdown) systemctl poweroff ;;
              *Reboot)   systemctl reboot ;;
              *Sleep)    systemctl hibernate ;;
              *Logout)   ${
              if host.wm == "hyprland"
              then "hyprctl dispatch exit"
              else "niri msg action quit"
            } ;;
              *Lock)     ${pkgs.swaylock-effects}/bin/swaylock -f ;;
            esac
          '')

          (pkgs.writeShellScriptBin "fuzzel-hub" ''
            dmenu_line() {
              printf '%s\0icon\x1f%s\n' "$1" "$2"
            }

            selection=$(
              {
                dmenu_line "Clipboard" "edit-copy"
                dmenu_line "Audio" "audio-volume-high"
                dmenu_line "Emoji" "insert-emoticon"
                dmenu_line "Font" "preferences-desktop-font"
                dmenu_line "Bluetooth" "bluetooth"
                ${lib.optionalString isLaptop ''dmenu_line "Battery" "battery"''}
                ${lib.optionalString msiEc ''dmenu_line "Fans (MSI)" "temperature-normal"''}
                dmenu_line "Notification" "preferences-desktop-notification"
                dmenu_line "Power" "system-shutdown"
              } | fuzzel --dmenu --prompt="Hub: "
            )

            case "$selection" in
              *Clipboard) fuzzel-clipboard ;;
              *Audio)     fuzzel-audio ;;
              *Emoji)     fuzzel-emoji ;;
              *Font)      fuzzel-font ;;
              *Bluetooth) ${host.defaults.terminal} -e bluetui ;;
              ${lib.optionalString isLaptop ''*Battery) fuzzel-battery ;;''}
              ${lib.optionalString msiEc ''*Fans\ \(MSI\)) ${host.defaults.terminal} -e msi-tui ;;''}
              *Notification) fuzzel-notifications ;;
              *Power)     fuzzel-power ;;
            esac
          '')
        ]
        ++ lib.optionals isLaptop [
          (pkgs.writeShellApplication {
            name = "fuzzel-battery";
            runtimeInputs =
              (with pkgs; [
                upower
                libnotify
                fuzzel
                brightnessctl
                gawk
                less
              ])
              ++ lib.optional (host.wm == "niri") pkgs.niri-stable;
            text = ''
              terminal="${host.defaults.terminal}"
              battery_dev=$(upower -e | grep -i battery | head -1)
              # Reference the system tlp (single NixOS build) rather than the
              # home-manager pkgs.tlp; the sudo NOPASSWD rule in
              # power-manager.nix is scoped to exactly this path.
              tlp_bin=/run/current-system/sw/bin/tlp
              tlp_stat=/run/current-system/sw/bin/tlp-stat

              battery_prompt() {
                if [ -z "$battery_dev" ]; then
                  echo "No battery"
                  return
                fi
                upower -i "$battery_dev" | awk -F: '
                  /state/ { gsub(/^[ \t]+/, "", $2); state = $2 }
                  /percentage/ { gsub(/^[ \t]+/, "", $2); pct = $2 }
                  /time to full/ { gsub(/^[ \t]+/, "", $2); tf = $2 }
                  /time to empty/ { gsub(/^[ \t]+/, "", $2); te = $2 }
                  END {
                    time = (state ~ /charging/) ? tf : te
                    printf "%s %s %s", pct, state, time
                  }'
              }

              current_profile() {
                "$tlp_stat" -m 2>/dev/null | awk -F/ '{ print $1; exit }'
              }

              tlp_mode() {
                "$tlp_stat" -m 2>/dev/null
              }

              menu_prompt() {
                local prompt mode
                prompt=$(battery_prompt)
                mode=$(tlp_mode)
                printf '%s | TLP: %s' "$prompt" "''${mode:-?}"
              }

              dmenu_line() {
                printf '%s\0icon\x1f%s\n' "$1" "$2"
              }

              pick_power_profile() {
                local current selection profile_cmd profile label
                current=$(current_profile)
                selection=$(
                  {
                    for entry in "performance:Performance" "balanced:Balanced" "power-saver:Power saver"; do
                      profile=''${entry%%:*}
                      label=''${entry#*:}
                      if [ "$profile" = "$current" ]; then
                        dmenu_line "$label" "object-select"
                      else
                        printf '%s\n' "$label"
                      fi
                    done
                  } | fuzzel --dmenu --prompt="Power profile: "
                )
                [ -n "$selection" ] || return 0
                case "$selection" in
                  *Performance*) profile_cmd="performance" ;;
                  *Balanced*) profile_cmd="balanced" ;;
                  *Power\ saver*) profile_cmd="power-saver" ;;
                  *) return 0 ;;
                esac
                if sudo -n "$tlp_bin" "$profile_cmd"; then
                  ${throttleRefresh}
                  notify-send "Power" "Profile: $(tlp_mode)"
                else
                  notify-send "Power" "Failed to set power profile"
                fi
              }

              show_full_report() {
                tmp=$(mktemp)
                {
                  echo "=== Battery ==="
                  upower -i "$battery_dev" 2>/dev/null || echo "No battery device"
                  echo
                  echo "=== TLP Battery ==="
                  "$tlp_stat" -b 2>/dev/null || echo "TLP battery stats unavailable"
                  echo
                  echo "=== TLP System ==="
                  "$tlp_stat" -s 2>/dev/null || echo "TLP system stats unavailable"
                } > "$tmp"
                "$terminal" -e less -R "$tmp"
                rm -f "$tmp"
              }

              notify_details() {
                notify-send -t 15000 "Battery" "$(
                  {
                    upower -i "$battery_dev" 2>/dev/null
                    echo
                    "$tlp_stat" -b 2>/dev/null | sed -n '1,20p'
                  } | fold -s -w 60
                )"
              }

              while true; do
                selection=$(
                  {
                    dmenu_line "Power profile" "cpu"
                    dmenu_line "Brightness +" "list-add"
                    dmenu_line "Brightness -" "list-remove"
                    dmenu_line "Full report" "document-open"
                    dmenu_line "Notify details" "preferences-desktop-notification"
                    dmenu_line "Close" "window-close"
                  } | fuzzel --dmenu --prompt="$(menu_prompt): "
                )
                case "$selection" in
                  *Power\ profile*) pick_power_profile ;;
                  *Brightness\ +*) brightnessctl set +5% ;;
                  *Brightness\ -*) brightnessctl set 5%- ;;
                  *Full*) show_full_report; break ;;
                  *Notify*) notify_details ;;
                  *Close*|"") break ;;
                esac
              done
            '';
          })
        ];
    };
  };
}
