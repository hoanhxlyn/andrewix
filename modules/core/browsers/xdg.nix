{
  core.browsers.xdg = {host, ...}: let
    browserExecs = {
      zen = "zen-beta";
      helium = "helium";
      firefox = "firefox";
    };
    browserDesktops = {
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
            value = browserDesktops.${host.defaultBrowser};
          })
          mimeTypes
        );
      };
      home.sessionVariables.BROWSER = browserExecs.${host.defaultBrowser};
    };
  };
}
