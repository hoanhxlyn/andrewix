{
  den.aspects.my.menu-launcher.fuzzel = hostConf: let
    terminal = hostConf.host.terminal;
  in {
    homeManager = {pkgs, ...}: {
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            terminal = terminal.name;
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
          sinks_json=$(pw-dump | jq -c '[.[] | select(.info.props["media.class"] == "Audio/Sink") | {id: .id, name: .info.props["node.name"], desc: .info.props["node.description"]}]')
          if [ -z "$sinks_json" ] || [ "$sinks_json" = "[]" ]; then
            notify-send "Audio" "No sinks found"
            exit 1
          fi
          default_name=$(pw-metadata -n default | grep 'default.audio.sink' | sed -r "s/.*value:'(.*)'.*/\1/" | jq -r '.name' 2>/dev/null)
          mapfile -t ids   < <(echo "$sinks_json" | jq -r '.[] | .id')
          mapfile -t names < <(echo "$sinks_json" | jq -r '.[] | .name')
          mapfile -t descs < <(echo "$sinks_json" | jq -r '.[] | .desc')
          selection=$(for i in "''${!ids[@]}"; do
            if [ "''${names[$i]}" = "$default_name" ]; then
              echo "󰄬 ''${descs[$i]}"
            else
              echo "  ''${descs[$i]}"
            fi
          done | fuzzel --dmenu --prompt="Audio: " --index)
          if [ -n "$selection" ]; then
            wpctl set-default "''${ids[$selection]}"
            notify-send "Audio" "Switched to ''${descs[$selection]}" 2>/dev/null || true
          fi
        '')

        (pkgs.writeShellScriptBin "fuzzel-emoji" ''
          EMOJI_FILE="$HOME/.cache/emoji_list.txt"
          if [ ! -f "$EMOJI_FILE" ]; then
            notify-send "Fuzzel" "Downloading emoji list..."
            curl -s https://raw.githubusercontent.com/muan/emojilib/main/dist/emoji-en-US.json \
              | jq -r 'to_entries | .[] | "\(.key) \(.value[0])"' > "$EMOJI_FILE"
          fi
          selection=$(fuzzel --dmenu --prompt="Emoji: " < "$EMOJI_FILE")
          if [ -n "$selection" ]; then
            emoji=$(echo "$selection" | awk '{print $1}')
            echo -n "$emoji" | wl-copy
            notify-send "Emoji" "Copied $emoji to clipboard"
          fi
        '')

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
