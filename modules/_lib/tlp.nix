{pkgs}: let
  tlpStat = "${pkgs.tlp}/bin/tlp-stat";
in {
  # Raw "profile/power-source" string, e.g. "performance/AC" or "balanced/BAT"
  statusCmd = "${tlpStat} -m 2>/dev/null";
  # Just the profile name (before the slash), e.g. "performance"
  profileCmd = "${tlpStat} -m 2>/dev/null | awk -F/ '{ print $1; exit }'";
  # True when profile is "performance" and running on AC power
  isPerformanceOnAc = ''[ "$(${tlpStat} -m 2>/dev/null)" = "performance/AC" ]'';
}
