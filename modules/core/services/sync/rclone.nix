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
          EnvironmentFile = "${config.home.homeDirectory}/.config/sops-nix/rclone-env";
          # OAuth client can't be a store symlink: rclone rewrites rclone.conf on token refresh
          ExecStartPre = [
            "${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/${path}"
            (pkgs.writeShellScript "rclone-set-oauth-client" ''
              conf=${config.home.homeDirectory}/.config/rclone/rclone.conf
              ${pkgs.gnused}/bin/sed -i \
                -e '/^\[gdrive\]/,/^\[/ { /^client_id = /d; /^client_secret = /d; }' \
                -e "/^\[gdrive\]/a client_id = ''${RCLONE_DRIVE_CLIENT_ID}" \
                -e "/^\[gdrive\]/a client_secret = ''${RCLONE_DRIVE_CLIENT_SECRET}" \
                "$conf"
            '')
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
