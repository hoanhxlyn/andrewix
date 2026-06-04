{
  den.aspects.my.menu-launcher.fuzzel = hostConf: let
    terminal = hostConf.host.terminal;
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
      home.file.".local/share/icons/hicolor/48x48/apps/cursor.png".source = "${pkgs.code-cursor}/share/icons/hicolor/1024x1024/apps/cursor.png";

      # Utilities scripts
      home.packages = [
        pkgs.libnotify
        pkgs.papirus-icon-theme

        (pkgs.writeShellScriptBin "fuzzel-clipboard" ''
          CACHE="$HOME/.cache/cliphist-previews"
          mkdir -p "$CACHE"

          selection=$(
            {
              printf 'Clear History\n'
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
              notify-send "Clipboard history cleared!"
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
          selection=$(for i in "''${!ids[@]}"; do
            if [ "''${defs[$i]}" = "1" ]; then
              echo "󰄬 ''${descs[$i]}"
            else
              echo "  ''${descs[$i]}"
            fi
          done | fuzzel --dmenu --prompt="Audio: " --index)
          if [ -n "$selection" ]; then
            wpctl set-default "''${ids[$selection]}"
            notify-send "Audio" "Switched to ''${descs[$selection]}"
          fi
        '')

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

        (pkgs.writeShellScriptBin "fuzzel-power" ''
          SELECTIONS=" Shutdown\n󰜉 Reboot\n󰒲 Sleep\n󰗽 Logout\n󰌾 Lock"
          selection=$(echo -e "$SELECTIONS" | fuzzel --dmenu --prompt="System: ")
          case "$selection" in
            *Shutdown) systemctl poweroff ;;
            *Reboot)   systemctl reboot ;;
            *Sleep)    systemctl hibernate ;;
            *Logout)   niri msg action quit ;;
            *Lock)     loginctl lock-session ;;
          esac
        '')

        (pkgs.writeShellApplication {
          name = "fuzzel-battery";
          runtimeInputs = with pkgs; [
            upower
            tlp
            libnotify
            fuzzel
            polkit
            brightnessctl
            gawk
            less
          ];
          text = ''
            terminal="${terminal.name}"
            battery_dev=$(upower -e | grep -i battery | head -1)

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
                  printf "󰁹 %s %s %s", pct, state, time
                }'
            }

            platform_profile() {
              if [ -r /sys/firmware/acpi/platform_profile ]; then
                cat /sys/firmware/acpi/platform_profile
              fi
            }

            tlp_mode() {
              tlp-stat -s 2>/dev/null | awk '/^Mode[[:space:]]+=/ { print $3; exit }'
            }

            menu_prompt() {
              local prompt plat tlp
              prompt=$(battery_prompt)
              plat=$(platform_profile)
              tlp=$(tlp_mode)
              if [ -n "$plat" ]; then
                printf '%s | Platform: %s | TLP: %s' "$prompt" "$plat" "''${tlp:-?}"
              else
                printf '%s | TLP: %s' "$prompt" "''${tlp:-?}"
              fi
            }

            pick_platform_profile() {
              local choices current selection profile
              choices=$(cat /sys/firmware/acpi/platform_profile_choices 2>/dev/null) || return 1
              current=$(platform_profile)
              selection=$(
                for profile in $choices; do
                  if [ "$profile" = "$current" ]; then
                    echo "󰄬 $profile"
                  else
                    echo "  $profile"
                  fi
                done | fuzzel --dmenu --prompt="Platform profile: "
              )
              [ -n "$selection" ] || return 0
              profile=''${selection#* }
              if echo "$profile" | pkexec tee /sys/firmware/acpi/platform_profile >/dev/null; then
                notify-send "Power" "Platform profile: $profile"
              else
                notify-send "Power" "Failed to set platform profile"
              fi
            }

            show_full_report() {
              tmp=$(mktemp)
              {
                echo "=== Battery ==="
                upower -i "$battery_dev" 2>/dev/null || echo "No battery device"
                echo
                echo "=== TLP Battery ==="
                tlp-stat -b 2>/dev/null || echo "TLP battery stats unavailable"
                echo
                echo "=== TLP System ==="
                tlp-stat -s 2>/dev/null || echo "TLP system stats unavailable"
              } > "$tmp"
              "$terminal" --class power-panel -T "Power Panel" -e less -R "$tmp"
              rm -f "$tmp"
            }

            notify_details() {
              notify-send -t 15000 "Battery" "$(
                {
                  upower -i "$battery_dev" 2>/dev/null
                  echo
                  tlp-stat -b 2>/dev/null | sed -n '1,20p'
                } | fold -s -w 60
              )"
            }

            while true; do
              menu="󰋊 Full report\n󰂪 Notify details\n Close"
              if [ -r /sys/firmware/acpi/platform_profile_choices ]; then
                menu="󰕒 Platform profile\n$menu"
              fi
              if [ -n "$battery_dev" ]; then
                menu="󰃠 Brightness +\n󰃟 Brightness -\n$menu"
              fi
              selection=$(
                echo -e "$menu" | fuzzel --dmenu --prompt="$(menu_prompt): "
              )
              case "$selection" in
                *Platform*) pick_platform_profile ;;
                *Brightness\ +*) brightnessctl set +5% ;;
                *Brightness\ -*) brightnessctl set 5%- ;;
                *Full*) show_full_report; break ;;
                *Notify*) notify_details ;;
                *Close*|"") break ;;
              esac
            done
          '';
        })

        (pkgs.writeShellScriptBin "fuzzel-hub" ''
          MENU="󰅇 Clipboard\n󰍯 Audio\n󰱨 Emoji\n󰂯 Bluetooth\n󰁹 Battery\n󰐥 Power"
          selection=$(echo -e "$MENU" | fuzzel --dmenu --prompt="Hub: ")
          case "$selection" in
            *Clipboard) fuzzel-clipboard ;;
            *Audio)     fuzzel-audio ;;
            *Emoji)     fuzzel-emoji ;;
            *Bluetooth) blueman-manager ;;
            *Battery)   fuzzel-battery ;;
            *Power)     fuzzel-power ;;
          esac
        '')
      ];
    };
  };
}
