{__findFile, ...}: {
  den.aspects = {
    workstation.includes = [
      (<den/batteries/import-tree/host> ../../hosts)
      <core.hardware>
      <core.services>
      <core.i18n>
      <core.timezone>
      <core.git>
      <core.agents>
      <core.shell>
      <core.browsers>
      <core.media>
      <core.desktop>
      <core.office>
      <core.editor>
      <core.terminals>
      <core.gui>
    ];

    andrew-laptop.provides.to-users.includes = [
      <workstation>
      <core.hardware.power-manager>
      <core.hardware.intel-vaapi>
    ];
    andrew-pc.provides.to-users.includes = [
      <workstation>
      <core.hardware.nvidia>
    ];
  };
}
