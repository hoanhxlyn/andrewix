{lib, ...}: {
  core.desktop.menu-launcher.fuzzel = {host, ...}: let
    inherit (host) terminal;
    isLaptop = host.isLaptop or false;
  in {
    homeManager = {pkgs, ...}: {
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            terminal = "${terminal.name} -e";
            show-actions = true;
            width = 50;
            lines = 10;
            horizontal-pad = builtins.mul terminal.padding 2;
            inner-pad = builtins.mul terminal.padding 2;
            vertical-pad = builtins.mul terminal.padding 2;
            line-height = 30;
            image-size-ratio = 1.0;
            icon-theme = "Papirus-Dark";
            scaling-filter = "lanczos3";
          };
          border = {
            width = 1;
            radius = 15;
          };
        };
      };

      home.file.".local/share/icons/hicolor/48x48/apps/yazi.png".source = "${pkgs.yazi}/share/pixmaps/yazi.png";

      # Utilities scripts
      home.packages =
        [
          pkgs.libnotify
          pkgs.papirus-icon-theme

          (pkgs.writeShellScriptBin "fuzzel-clipboard" ''
            CACHE="$HOME/.cache/cliphist-previews"
            mkdir -p "$CACHE"

            dmenu_line() {
              printf '%s\0icon\x1f%s\n' "$1" "$2"
            }

            selection=$(
              {
                dmenu_line "Clear History" "edit-clear"
                cliphist list | head -n 20 | while IFS=$'\t' read -r id display; do
                  if [[ "$display" == "[[ binary data"* ]]; then
                    img="$CACHE/$id.png"
                    if [[ ! -f "$img" ]]; then
                      printf '%s\t%s' "$id" "$display" | cliphist decode > "$img" 2>/dev/null
                    fi
                    printf '%s\t%s\0icon\x1f%s\n' "$id" "$display" "$img"
                  else
                    printf '%s\t%s\n' "$id" "$display"
                  fi
                done
              } | fuzzel --dmenu --prompt="Clipboard: "
            )

            if [ -n "$selection" ]; then
              if [ "$selection" = "Clear History" ]; then
                cliphist wipe
                rm -f "$CACHE"/*.png
                rm -f "$HOME/.cache/cliphist/db"
                notify-send "Clipboard history cleared! (history + cache purged)"
              else
                printf '%s' "$selection" | cliphist decode | wl-copy
                notify-send "Copied to clipboard!"
              fi
            fi
          '')

          (pkgs.writeShellScriptBin "fuzzel-audio" ''
            mapfile -t sink_lines < <(
              wpctl status | awk '
                /Sinks:/ { in_sinks=1; next }
                in_sinks && /Sources:/ { in_sinks=0 }
                in_sinks && /[0-9]+\..*\[vol:/ {
                  is_def = ($0 ~ /\*/) ? 1 : 0
                  match($0, /[0-9]+/, m); id = m[0]
                  desc = $0; sub(/.*[0-9]+\. /, "", desc); sub(/[[:space:]]+\[vol:.*/, "", desc)
                  gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
                  print id "\t" desc "\t" is_def
                }
              '
            )
            if [ "''${#sink_lines[@]}" -eq 0 ]; then
              notify-send "Audio" "No sinks found"
              exit 1
            fi
            mapfile -t ids   < <(printf '%s\n' "''${sink_lines[@]}" | cut -f1)
            mapfile -t descs < <(printf '%s\n' "''${sink_lines[@]}" | cut -f2)
            mapfile -t defs  < <(printf '%s\n' "''${sink_lines[@]}" | cut -f3)
            dmenu_line() {
              printf '%s\0icon\x1f%s\n' "$1" "$2"
            }
            selection=$(for i in "''${!ids[@]}"; do
              if [ "''${defs[$i]}" = "1" ]; then
                dmenu_line "''${descs[$i]}" "object-select"
              else
                printf '%s\n' "''${descs[$i]}"
              fi
            done | fuzzel --dmenu --prompt="Audio: " --index)
            if [ -n "$selection" ]; then
              wpctl set-default "''${ids[$selection]}"
              notify-send "Audio" "Switched to ''${descs[$selection]}"
            fi
          '')

          (pkgs.writeShellApplication {
            name = "fuzzel-notifications";
            runtimeInputs = with pkgs; [jq libnotify fuzzel mako];
            text = ''
              history=$(makoctl history -j 2>/dev/null)

              if [ -z "$history" ] || [ "$history" = "[]" ]; then
                notify-send "Notification History" "No history"
                exit 0
              fi

              count=$(echo "$history" | jq 'length')
              if [ "$count" -eq 0 ]; then
                notify-send "Notification History" "No history"
                exit 0
              fi

              dmenu_line() {
                printf '%s\0icon\x1f%s\n' "$1" "$2"
              }

              selection=$(
                {
                  dmenu_line "Restore Most Recent" "preferences-desktop-notification"
                  echo "$history" | jq -r '.[:5] | .[] | "\(.app_name // "Unknown") | \(.summary)"' | while IFS= read -r line; do
                    dmenu_line "$line" "preferences-desktop-notification"
                  done
                } | fuzzel --dmenu --prompt="History: "
              )

              if [ "$selection" = "Restore Most Recent" ]; then
                makoctl restore
              elif [ -n "$selection" ]; then
                app_name=''${selection%% | *}
                summary=''${selection#* | }

                body=$(echo "$history" | jq -r --arg app "$app_name" --arg sum "$summary" '.[] | select(.app_name == $app and .summary == $sum) | .body // "No body" | tostring' | head -1)
                urgency=$(echo "$history" | jq -r --arg app "$app_name" --arg sum "$summary" '.[] | select(.app_name == $app and .summary == $sum) | .urgency // "normal" | tostring' | head -1)

                if [ "$body" != "null" ] && [ -n "$body" ]; then
                  notify-send -u "$urgency" "$app_name: $summary" "$body"
                else
                  notify-send "$app_name: $summary"
                fi
              fi
            '';
          })

          (pkgs.writeShellApplication {
            name = "fuzzel-emoji";
            runtimeInputs = with pkgs; [curl jq wl-clipboard libnotify fuzzel];
            text = ''
              EMOJI_FILE="$HOME/.cache/emoji_list.txt"
              if [ ! -f "$EMOJI_FILE" ] || [ ! -s "$EMOJI_FILE" ]; then
                notify-send "Fuzzel" "Downloading emoji list..."
                mkdir -p "$(dirname "$EMOJI_FILE")"
                curl -sf https://raw.githubusercontent.com/muan/emojilib/main/dist/emoji-en-US.json \
                  | jq -r 'to_entries | .[] | "\(.key) \(.value[0])"' > "$EMOJI_FILE"
              fi
              selection=$(fuzzel --dmenu --prompt="Emoji: " < "$EMOJI_FILE")
              if [ -n "$selection" ]; then
                emoji=$(echo "$selection" | awk '{print $1}')
                echo -n "$emoji" | wl-copy
                notify-send "Emoji" "Copied $emoji to clipboard"
              fi
            '';
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
              *Logout)   niri msg action quit ;;
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
                dmenu_line "Notification" "preferences-desktop-notification"
                dmenu_line "Power" "system-shutdown"
              } | fuzzel --dmenu --prompt="Hub: "
            )

            case "$selection" in
              *Clipboard) fuzzel-clipboard ;;
              *Audio)     fuzzel-audio ;;
              *Emoji)     fuzzel-emoji ;;
              *Font)      fuzzel-font ;;
              *Bluetooth) ${terminal.name} -e bluetui ;;
              ${lib.optionalString isLaptop ''*Battery) fuzzel-battery ;;''}
              *Notification) fuzzel-notifications ;;
              *Power)     fuzzel-power ;;
            esac
          '')
        ]
        ++ lib.optionals isLaptop [
          (pkgs.writeShellApplication {
            name = "fuzzel-battery";
            runtimeInputs = with pkgs; [
              upower
              libnotify
              fuzzel
              brightnessctl
              gawk
              less
            ];
            text = ''
              terminal="${terminal.name}"
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
