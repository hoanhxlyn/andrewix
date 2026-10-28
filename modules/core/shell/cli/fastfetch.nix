{self, ...}: {
  core.cli.fastfetch = {
    homeManager = {
      host,
      lib,
      ...
    }: {
      programs.fastfetch.enable = true;
      programs.fastfetch.settings.logo.type = "file";
      programs.fastfetch.settings.logo.source = "${self}/config/arts/bongo_cat.txt";
      programs.fastfetch.settings.logo.padding.top = 1;
      programs.fastfetch.settings.display.separator = " ";
      programs.fastfetch.settings.modules =
        [
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
            "key" = "{#31}├─  term";
            "type" = "terminal";
          }
          {
            "key" = "{#32}├─  shell";
            "type" = "shell";
          }
          {
            "key" = "{#33}├─ 󰻠 cpu";
            "type" = "cpu";
          }
        ]
        # GPU row only when the host declares one (fastfetch errors when no GPU is found).
        ++ lib.optional (host.gpu != []) {
          "key" = "{#34}├─ 󰢮 gpu";
          "type" = "gpu";
        }
        ++ [
          {
            "key" = "{#35}├─ 󰉉 disk";
            "type" = "disk";
            "folders" = "/";
          }
          {
            "key" = "{#36}├─ 󰍛 memory";
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
}
