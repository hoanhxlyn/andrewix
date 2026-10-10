{self, ...}: {
  core.cli.fastfetch = {
    homeManager = {
      programs.fastfetch = {
        enable = true;
        settings = {
          logo = {
            type = "file";
            source = "${self}/config/arts/bongo_cat.txt";
            padding.top = 1;
          };
          display.separator = " ";
          modules = [
            {
              "key" = "{#31}╭─ 󰇇 user";
              "type" = "title";
              "format" = "{user-name}";
            }
            {
              "key" = "{#32}├─ 󰇅 hname";
              "type" = "title";
              "format" = "{host-name}";
            }
            {
              "key" = "{#33}├─ 󰅐 uptime";
              "type" = "uptime";
            }
            {
              "key" = "{#34}├─ {icon} distro";
              "type" = "os";
            }
            {
              "key" = "{#35}├─ 󰌽 kernel";
              "type" = "kernel";
            }
            {
              "key" = "{#36}├─ 󰇄 desktop";
              "type" = "de";
            }
            {
              "key" = "{#31}├─  term";
              "type" = "terminal";
            }
            {
              "key" = "{#32}├─  shell";
              "type" = "shell";
            }
            {
              "key" = "{#33}├─ 󰻠 cpu";
              "type" = "command";
              "text" = ''fastfetch -s cpu --format json | jq -r '.[0].result | (.cpu | split(" ") | last) + " @ " + (.frequency.max/1000|tostring) + "GHz"' '';
            }
            {
              "key" = "{#34}├─ 󰉉 disk";
              "type" = "disk";
              "folders" = "/";
            }
            {
              "key" = "{#35}├─ 󰍛 memory";
              "type" = "memory";
            }
            {
              "key" = "{#39}╰─  colors";
              "type" = "colors";
              "symbol" = "circle";
            }
          ];
        };
      };
    };
  };
}
