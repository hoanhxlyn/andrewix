{__findFile ? __findFile, ...}: {
  my.workstation.provides = {
    # for real-world hw machine
    hw.includes = [
      <my.workstation/base>
      <vix.bootable>
      <vix.gnome-desktop>
    ];

    base.includes = [
      <vix.dev-laptop>
    ];
  };
}
