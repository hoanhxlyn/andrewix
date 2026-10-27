{__findFile, ...}: {
  core.office = {
    includes = [
      <core.office.onlyoffice>
      # <core.office.timr-tui>
      <core.office.teams>
      <core.office.markdown>
    ];
  };
}
