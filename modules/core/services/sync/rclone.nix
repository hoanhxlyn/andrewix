{
  core.sync.rclone = {host, ...}: let
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
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/${path}";
          ExecStart = ''
            ${pkgs.rclone}/bin/rclone mount gdrive: ${config.home.homeDirectory}/${path} \
            --allow-non-empty \
            --vfs-cache-max-age 24h \
            --dir-cache-time 1h \
            --poll-interval 1m \
            --vfs-cache-mode full \
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
