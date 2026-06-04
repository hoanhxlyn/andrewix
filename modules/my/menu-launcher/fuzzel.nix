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
            icon-theme = "Papirus-Dark";
            show-actions = true;
            width = 50;
            lines = 10;
            horizontal-pad = builtins.mul terminal.padding 2;
            inner-pad = builtins.mul terminal.padding 2;
            vertical-pad = builtins.mul terminal.padding 2;
            line-height = 30;
            image-size-ratio = 1.0;
          };
          border = {
            width = 1;
            radius = 15;
          };
        };
      };

      # Utilities scripts
      home.packages = [
        pkgs.libnotify

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

        (pkgs.writeShellScriptBin "fuzzel-hub" ''
          MENU="󰅇 Clipboard\n󰍯 Audio\n󰱨 Emoji\n󰂯 Bluetooth\n󰐥 Power"
          selection=$(echo -e "$MENU" | fuzzel --dmenu --prompt="Hub: ")
          case "$selection" in
            *Clipboard) fuzzel-clipboard ;;
            *Audio)     fuzzel-audio ;;
            *Emoji)     fuzzel-emoji ;;
            *Bluetooth) blueman-manager ;;
            *Power)     fuzzel-power ;;
          esac
        '')
      ];
    };
  };
}
