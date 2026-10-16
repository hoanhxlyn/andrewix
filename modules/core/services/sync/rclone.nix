{
  core.services.sync.rclone = {host, ...}: let
    path = host.rclone.path;
  in {
    nixos = {
      programs.fuse.enable = true;
    };
    homeManager = {
      pkgs,
      config,
      ...
    }: {
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
          Type = "notify";
          ExecStartPre = [
            # A crashed rclone leaves a stale FUSE mount; mkdir then fails with ENOTCONN.
            # Kill holders, lazily unmount, then (re)create the mount point.
            "-${pkgs.psmisc}/bin/fuser -k ${config.home.homeDirectory}/${path}"
            "-${pkgs.fuse}/bin/fusermount -uz ${config.home.homeDirectory}/${path}"
            "${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/${path}"
          ];
          ExecStart = ''
            ${pkgs.rclone}/bin/rclone mount gdrive: ${config.home.homeDirectory}/${path} \
            --allow-non-empty \
            --vfs-cache-max-age 24h \
            --dir-cache-time 24h \
            --poll-interval 5m \
            --vfs-cache-mode full \
            --vfs-cache-max-size 5G \
            --config %h/.config/rclone/rclone.conf
          '';
          ExecStop = "${pkgs.fuse}/bin/fusermount -u ${config.home.homeDirectory}/${path}";
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };
    };
  };
}
