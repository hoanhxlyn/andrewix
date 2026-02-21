{
  andrew.browsers.provides.brave.homeManager = {pkgs, ...}: let
    keepass = pkgs.keepassxc;
  in {
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
        {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock
        {id = "oboonakemofpalcgghocfoadofidjkkk";} # keepassxc
        {id = "fmkadmapgofadopljbjfkapdkoienihi";} # React dev tools
      ];
      nativeMessagingHosts = [keepass];
    };
  };
}
