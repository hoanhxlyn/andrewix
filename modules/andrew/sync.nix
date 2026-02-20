{
  andrew.sync = path: {
    homeManager = {pkgs, ...}: {
      programs = {
        rclone.enable = true;
        keepassxc = {
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
      systemd.user.services = {
        rclone-gdrive = {
          Unit = {
            Description = "Sync GG drive via rclone";
            After = ["default.target"];
          };
          Install = {
            WantedBy = ["default.target"];
          };
          Service = {
            Type = "simple";
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /home/andrew/${path}";
            ExecStart = ''
              ${pkgs.rclone}/bin/rclone mount gdrive: /home/andrew/${path} \
              --vfs-cache-max-age 24h \
              --dir-cache-time 1h \
              --vfs-cache-mode full \
              --config %h/.config/rclone/rclone.conf
            '';
            ExecStop = "${pkgs.fuse}/bin/fusermount -u /home/andrew/${path}";
            Restart = "on-failure";
            RestartSec = "10s";
          };
        };
        keepassxc-autostart = {
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
  };
}
