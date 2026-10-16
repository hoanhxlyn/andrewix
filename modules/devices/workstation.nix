{
  __findFile,
  lib,
  ...
}: {
  den.aspects.workstation.includes = [
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
    ({host, ...}: {includes = lib.optional host.enableGaming <core.gaming>;})
  ];
}
