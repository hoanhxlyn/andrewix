# Replaced pkgs.libreoffice-stable. The old LibreOffice profile is kept at
# ~/.config/libreoffice for reference; to go back, re-add the package (and the
# calc/writer/impress desktop ids) here.
{
  core.office.onlyoffice.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.onlyoffice-desktopeditors];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = builtins.listToAttrs (map (m: {
          name = m;
          value = "onlyoffice-desktopeditors.desktop";
        }) [
          "text/csv"
          "application/vnd.ms-excel"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          "application/vnd.oasis.opendocument.spreadsheet"
          "application/msword"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          "application/vnd.oasis.opendocument.text"
          "application/vnd.ms-powerpoint"
          "application/vnd.openxmlformats-officedocument.presentationml.presentation"
          "application/vnd.oasis.opendocument.presentation"
        ]);
    };
  };
}
