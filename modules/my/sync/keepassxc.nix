{
  den.aspects.my.sync.keepassxc = {host, ...}: let
    path = host.rclone.path;
  in {
    nixos = {pkgs, ...}: {
      environment.etc."chromium/native-messaging-hosts/org.keepassxc.keepassxc_browser.json".text = builtins.toJSON {
        name = "org.keepassxc.keepassxc_browser";
        description = "KeePassXC integration with native messaging support";
        path = "${pkgs.keepassxc}/bin/keepassxc-proxy";
        type = "stdio";
        allowed_origins = [
          "chrome-extension://oboonakemofpalcgghocfoadofidjkkk/"
          "chrome-extension://pdffhmdngciaglkoonimfcmckehcpafo/"
        ];
      };
    };
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [libsecret procps];
      programs.keepassxc = {
        enable = true;
        settings = {
          General = {
            ConfigVersion = 2;
            UpdateCheckMessageShown = true;
            BackupBeforeSave = true;
            BackupFilePathPattern = "/home/andrew/${path}/backups/Keepasx/{DB_FILENAME}.old.kdbx";
          };
          GUI = {
            MonospaceNotes = true;
            ColorPasswords = true;
            ShowTrayIcon = true;
            TrayIconAppearance = "colorful";
            MinimizeOnClose = true;
            MinimizeToTray = false;
            CompactMode = false;
            ShowExpiredEntriesOnDatabaseUnlock = false;
            HidePasswords = false;
          };
          Browser = {
            Enabled = true;
            Browser_AllowLocalhostWithPasskeys = true;
            UpdateBinaryPath = false;
          };
          PasswordGenerator = {
            Length = 18;
          };
          Security = {
            LockDatabaseScreenLock = false;
            IconDownloadFallback = true;
            PasswordHidden = false;
            HidePasswordPreviewPanel = false;
            PasswordEmptyPlaceholder = false;
            PasswordRepeatVisible = false;
            HideTotpPreviewPanel = true;
            LockDatabaseIdle = false;
          };
          FdoSecrets = {
            Enabled = false;
            ConfirmAccessItem = false;
          };
        };
      };
      systemd.user.services.keepassxc-autostart = {
        Unit = {
          Description = "Keepassxc";
          After = [
            "graphical-session-pre.target"
            "rclone-gdrive.service"
          ];
          Requires = ["rclone-gdrive.service"];
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
        Service = {
          Type = "simple";
          # Kill lingering gnome-keyring-daemon so KeePassXC can own Secret Service
          ExecStartPre = "-${pkgs.procps}/bin/pkill -9 gnome-keyring-daemon";
          ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
          Restart = "on-failure";
          RestartSec = "10s";
          # Ensure D-Bus session is available for Secret Service
          Environment = ["DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus"];
        };
      };
    };
  };
}
