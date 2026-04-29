{
  den.aspects.my._.sync._.keepassxc = path: {
    homeManager = {pkgs, ...}: {
      xdg.configFile."keepassxc/keepassxc.ini".force = true;
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
            CompactMode = true;
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
        };
      };
      systemd.user.services.keepassxc-autostart = {
        Unit = {
          Description = "Keepassxc";
          After = [
            "graphical-session-pre.target"
            "rclone-gdrive.service"
          ];
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };
    };
  };
}
