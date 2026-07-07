{
  core.media.mpv = {
    homeManager = {pkgs, ...}: let
      videoMimeTypes = [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/mpeg"
        "video/quicktime"
        "video/x-msvideo"
        "video/x-flv"
        "video/x-ms-wmv"
        "video/3gpp"
        "video/ogg"
      ];
    in {
      programs.mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          uosc
          thumbfast
          sponsorblock
          mpv-playlistmanager
          memo
          quality-menu
        ];
        config = {
          osc = false;
          border = false;
          hwdec = "auto-safe";
          save-position-on-quit = true;
          screenshot-format = "png";
          screenshot-directory = "~/Pictures/Screenshots/Mpv";
          sub-auto = "fuzzy";
          ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";
        };
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = builtins.listToAttrs (
          map (mime: {
            name = mime;
            value = "mpv.desktop";
          })
          videoMimeTypes
        );
      };
    };
  };
}
