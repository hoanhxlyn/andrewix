{pkgs, ...}: {
  programs.rclone.enable = true;
  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "Sync GG drive via rclone";
      After = ["default.target"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/mnt/gdrive";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount gdrive: %h/mnt/gdrive \
        --vfs-cache-max-age 24h \
        --dir-cache-time 1h \
        --vfs-cache-mode full \
        --config %h/.config/rclone/rclone.conf
      '';
      ExecStop = "${pkgs.fuse}/bin/fusermount -u %h/mnt/gdrive";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
