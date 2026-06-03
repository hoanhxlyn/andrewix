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
            prompt = "❯  ";
            placeholder = "What are we doing ?";
            show-actions = false;
            width = 50;
            lines = 10;
            horizontal-pad = builtins.mul terminal.padding 2;
            inner-pad = builtins.mul terminal.padding 2;
            vertical-pad = builtins.mul terminal.padding 2;
            line-height = 30;
            image-size-ratio = 0.5;
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
          selection=$(printf "Clear History\n%s" "$(cliphist list | head -n 20)" | fuzzel --dmenu --prompt="Clipboard: ")
          if [ -n "$selection" ]; then
            if [ "$selection" = "Clear History" ]; then
              cliphist wipe
              notify-send "Clipboard history cleared!"
            else
              echo "$selection" | cliphist decode | wl-copy
              notify-send "Copied to clipboard!"
            fi
          fi
        '')

        (pkgs.writeShellScriptBin "fuzzel-audio" ''
          mapfile -t sink_lines < <(pactl list sinks | awk '
            /^Sink #/      { idx = substr($2, 2) }
            /^\tName:/     { name = $2 }
            /^\tDescription:/ { sub(/^\tDescription: /, ""); print idx "\t" name "\t" $0 }
          ')
          if [ "''${#sink_lines[@]}" -eq 0 ]; then
            notify-send "Audio" "No sinks found"
            exit 1
          fi
          default_sink=$(pactl get-default-sink)
          mapfile -t names < <(printf '%s\n' "''${sink_lines[@]}" | cut -f2)
          mapfile -t descs < <(printf '%s\n' "''${sink_lines[@]}" | cut -f3)
          selection=$(for i in "''${!names[@]}"; do
            if [ "''${names[$i]}" = "$default_sink" ]; then
              echo "󰄬 ''${descs[$i]}"
            else
              echo "  ''${descs[$i]}"
            fi
          done | fuzzel --dmenu --prompt="Audio: " --index)
          if [ -n "$selection" ]; then
            pactl set-default-sink "''${names[$selection]}"
            notify-send "Audio" "Switched to ''${descs[$selection]}" 2>/dev/null || true
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
            *Sleep)    systemctl suspend ;;
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
