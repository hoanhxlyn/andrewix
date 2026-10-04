{
  core.hardware.sound.nixos = {pkgs, ...}: {
    services = {
      # ACP normally flips each HDMI PCM's "IEC958 Playback Switch" on when
      # its sink activates, but that logic is disabled along with ACP below,
      # so the switch stays off and no audio reaches the HDMI output even
      # though the sink opens fine. Unmute it ourselves when the card shows up.
      # The `id` attribute lives on the parent card device, not the controlC*
      # node, so match with ATTRS (parent walk), not ATTR (this device only).
      udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="sound", KERNEL=="controlC*", ATTRS{id}=="NVidia", \
          RUN+="${pkgs.alsa-utils}/bin/amixer -c NVidia cset name='IEC958 Playback Switch',index=0 on", \
          RUN+="${pkgs.alsa-utils}/bin/amixer -c NVidia cset name='IEC958 Playback Switch',index=1 on"
      '';

      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber = {
          extraScripts."auto-switch-bt-sink.lua" = ''
            local om = ObjectManager {
              Interest {
                type = "node",
                Constraint { "media.class", "equals", "Audio/Sink", type = "pw-global" },
                Constraint { "node.name", "matches", "bluez_output.*", type = "pw-global" },
              },
            }

            om:connect("object-added", function(_, node)
              local node_name = node.properties["node.name"]
              log:info("Bluetooth sink connected: " .. tostring(node_name))

              Core.require_api("default-nodes", function(default_nodes)
                local id = node["bound-id"]
                if id then
                  default_nodes:call("set-default-node", "Audio/Sink", id)
                  log:info("Default sink switched to: " .. tostring(node_name))
                end
              end)
            end)

            om:activate()
          '';

          extraConfig = {
            "60-auto-switch-bt" = {
              "wireplumber.components" = [
                {
                  name = "auto-switch-bt-sink.lua";
                  type = "script/lua";
                  provides = "custom.auto-switch-bt-sink";
                }
              ];
              "wireplumber.profiles" = {
                main."custom.auto-switch-bt-sink" = "required";
              };
            };

            # Profile selection order is: stored profile (state file) -> priority
            # rules -> best available profile. A stale "output:analog-stereo"
            # entry in ~/.local/state/wireplumber/default-profile thus wins over
            # every rule and leaves the card with no capture device at all, so
            # no app (Discord, Caprine, ...) sees a microphone. Disabling restore
            # makes selection rule-driven and deterministic on every boot.
            "50-no-profile-restore" = {
              "wireplumber.settings"."device.restore-profile" = false;
            };

            # The NVIDIA GPU's ACP (pulse-compat) profiles expose only one HDMI
            # sink at a time, so a second identical monitor never shows up as an
            # output. Disable ACP for that card and PipeWire creates a sink per
            # HDMI PCM, so both monitors are selectable simultaneously. The GPU
            # has 4 HDMI PCMs though, so also hide the 2 with no monitor attached
            # (devices 8 & 9) and give the 2 connected monitors (devices 3 & 7)
            # short, distinguishable names.
            "51-nvidia-hdmi-sinks" = {
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
                  actions.update-props = {
                    "node.description" = "Monitor 1 (HDMI)";
                    "audio.channels" = 2;
                    "audio.position" = "FL,FR";
                  };
                }
                {
                  matches = [{"node.name" = "alsa_output.pci-0000_01_00.1.playback.7.0";}];
                  actions.update-props = {
                    "node.description" = "Monitor 2 (HDMI)";
                    "audio.channels" = 2;
                    "audio.position" = "FL,FR";
                  };
                }
              ];
            };

            # The built-in HDA codec is duplex; force the duplex profile so its
            # internal mic is always exposed as a source. Matched on the stable
            # device.name, not the dynamic device.id.
            "52-builtin-duplex" = {
              "monitor.alsa.rules" = [
                {
                  matches = [{"device.name" = "alsa_card.pci-0000_00_1f.3";}];
                  actions.update-props."device.profile" = "output:analog-stereo+input:analog-stereo";
                }
              ];
            };
          };
        };
      };
    };
  };
}
