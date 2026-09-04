{
  core.office.libreoffice.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.libreoffice-stable];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = let
        forApp = app: mimes:
          builtins.listToAttrs (map (m: {
              name = m;
              value = "${app}.desktop";
            })
            mimes);
      in
        (forApp "calc" [
          "text/csv"
          "application/vnd.ms-excel"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          "application/vnd.oasis.opendocument.spreadsheet"
        ])
        // (forApp "writer" [
          "application/msword"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          "application/vnd.oasis.opendocument.text"
        ])
        // (forApp "impress" [
          "application/vnd.ms-powerpoint"
          "application/vnd.openxmlformats-officedocument.presentationml.presentation"
          "application/vnd.oasis.opendocument.presentation"
        ]);
    };
  };
}
