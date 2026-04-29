{
  den.aspects.my._.browsers._.brave.homeManager = {pkgs, ...}: {
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
        {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}
        {id = "oboonakemofpalcgghocfoadofidjkkk";}
        {id = "fmkadmapgofadopljbjfkapdkoienihi";}
      ];
      nativeMessagingHosts = [pkgs.keepassxc];
    };
  };
}
