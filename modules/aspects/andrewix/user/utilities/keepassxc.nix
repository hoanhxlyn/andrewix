{
  pkgs,
  username,
  ...
}: {
  programs = {
    keepassxc = {
      enable = true;
      settings = {
        General = {
          ConfigVersion = 2;
          UpdateCheckMessageShown = true;
          BackupBeforeSave = true;
          BackupFilePathPattern = "/home/${username}/mnt/gdrive/backups/Keepasx/{DB_FILENAME}.old.kdbx";
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
  };
  systemd = {
    user.services.keepassxc-autostart = {
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
}
