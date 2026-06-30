{
  core.browsers.xdg = {host, ...}: let
    desktopIds = {
      zen = "zen-beta.desktop";
      helium = "helium.desktop";
      firefox = "firefox.desktop";
    };
    mimeTypes = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "application/xhtml_xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/ftp"
    ];
  in {
    homeManager = {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = builtins.listToAttrs (
          map (mime: {
            name = mime;
            value = desktopIds.${host.defaultBrowser};
          })
          mimeTypes
        );
      };
      home.sessionVariables.BROWSER = host.defaultBrowser;
    };
  };
}
