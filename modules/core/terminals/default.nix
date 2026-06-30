{__findFile, ...}: {
  core.terminals = {
    includes = [
      <core/terminals/ghostty>
      <core/terminals/wezterm>
      <core/terminals/alacritty>
    ];
  };
}
