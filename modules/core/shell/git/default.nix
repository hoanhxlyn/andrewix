{__findFile, ...}: {
  core.git.includes = [
    <core.git.config>
    <core.git.credential>
    <core.git.difftastic>
    <core.git.lazygit>
  ];
}
