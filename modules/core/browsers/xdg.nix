{self, ...}: let
  browsers = import "${self}/modules/_lib/browsers.nix";
in {
  core.browsers.xdg = {host, ...}: let
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
            value = browsers.desktopIds.${host.defaultBrowser};
          })
          mimeTypes
        );
      };
      home.sessionVariables.BROWSER = browsers.executables.${host.defaultBrowser};
    };
  };
}
