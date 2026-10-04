{__findFile, ...}: {
  core.office = {
    includes = [
      <core.office.libreoffice>
      # <core.office.timr-tui>
      <core.office.teams>
      <core.office.markdown>
    ];
  };
}
