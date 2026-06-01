{
  den.aspects.my.browsers.brave.homeManager = {pkgs, ...}: {
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
        {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";}
        {id = "oboonakemofpalcgghocfoadofidjkkk";}
        {id = "fmkadmapgofadopljbjfkapdkoienihi";}
      ];
    };
  };
}
