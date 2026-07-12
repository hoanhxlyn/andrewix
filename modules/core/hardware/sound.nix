{
  core.sound.nixos = {
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # The NVIDIA GPU's ACP (pulse-compat) profiles expose only one HDMI
        # sink at a time, so a second identical monitor never shows up as an
        # output. Disable ACP for that card and PipeWire creates a sink per
        # HDMI PCM, so both monitors are selectable simultaneously. The GPU
        # has 4 HDMI PCMs though, so also hide the 2 with no monitor attached
        # (devices 8 & 9) and give the 2 connected monitors (devices 3 & 7)
        # short, distinguishable names.
        wireplumber.extraConfig."51-nvidia-hdmi-sinks" = {
          "monitor.alsa.rules" = [
            {
              matches = [{"device.name" = "alsa_card.pci-0000_01_00.1";}];
              actions.update-props."api.alsa.use-acp" = false;
            }
            {
              matches = [{"node.name" = "alsa_output.pci-0000_01_00.1.playback.8.0";}];
              actions.update-props."node.disabled" = true;
            }
            {
              matches = [{"node.name" = "alsa_output.pci-0000_01_00.1.playback.9.0";}];
              actions.update-props."node.disabled" = true;
            }
            {
              matches = [{"node.name" = "alsa_output.pci-0000_01_00.1.playback.3.0";}];
              actions.update-props."node.description" = "Monitor 1 (HDMI)";
            }
            {
              matches = [{"node.name" = "alsa_output.pci-0000_01_00.1.playback.7.0";}];
              actions.update-props."node.description" = "Monitor 2 (HDMI)";
            }
          ];
        };
      };
    };
  };
}
