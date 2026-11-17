{
  __findFile,
  lib,
  ...
}: {
  den.aspects.workstation.includes = [
    <core.hardware>
    <core.services>
    <core.services.gradient-client>
    # Joins the tailnet so gradient-client's cache (tailnet IP) is reachable.
    <core.services.tailscale>
    <core.locale>
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
