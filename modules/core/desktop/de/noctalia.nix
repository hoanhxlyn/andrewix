{inputs, ...}: {
  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  core.desktop.de.noctalia = {
    nixos.nix.settings = {
      extra-substituters = ["https://noctalia.cachix.org"];
      extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
    };

    homeManager = {
      imports = [
        inputs.noctalia.homeModules.default
      ];
      programs.noctalia-shell = {
        enable = true;
        settings = {
          settingsVersion = 0;
          bar = {
            barType = "simple";
            position = "top";
            density = "compact";
            showOutline = false;
            showCapsule = false;
            widgetSpacing = 6;
            contentPadding = 2;
            # fontScale = 1;
            enableExclusionZoneInset = true;
            marginVertical = 4;
            marginHorizontal = 4;
            frameThickness = 8;
            frameRadius = 12;
            outerCorners = true;
            hideOnOverview = false;
            displayMode = "always_visible";
            widgets = {
              left = [
                {
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
              ];
              center = [
                {
                  hideUnoccupied = false;
                  id = "Workspace";
                  labelMode = "none";
                }
              ];
              right = [
                {id = "Tray";}
                {id = "Network";}
                {
                  alwaysShowPercentage = false;
                  id = "Battery";
                  warningThreshold = 30;
                }
                {id = "Volume";}
                {id = "Bluetooth";}
                {id = "Brightness";}
                {
                  formatHorizontal = "HH:mm";
                  formatVertical = "HH mm";
                  id = "Clock";
                  useMonospacedFont = true;
                  usePrimaryColor = true;
                }
              ];
            };
          };

          dock = {
            enabled = false;
            position = "bottom";
            displayMode = "auto_hide";
            dockType = "floating";
            size = 1;
            onlySameOutput = true;
            groupApps = false;
            animationSpeed = 1;
          };

          general = {
            dimmerOpacity = 0.2;
            showScreenCorners = true;
            forceBlackScreenCorners = false;
            scaleRatio = 1;
            radiusRatio = 0.2;
            iRadiusRatio = 1;
            boxRadiusRatio = 1;
            screenRadiusRatio = 1;
            animationSpeed = 1;
            animationDisabled = false;
            compactLockScreen = false;
            lockOnSuspend = true;
            showSessionButtonsOnLockScreen = true;
            enableShadows = true;
            enableBlurBehind = true;
            shadowDirection = "bottom_right";
            shadowOffsetX = 2;
            shadowOffsetY = 3;
            allowPanelsOnScreenWithoutBar = true;
            showChangelogOnStartup = true;
            telemetryEnabled = false;
            enableLockScreenCountdown = true;
            lockScreenCountdownDuration = 10000;
            smoothScrollEnabled = true;
            avatarImage = "~/Pictures/Camera/avatar.jpg";
          };

          colorSchemes = {
            useWallpaperColors = false;
            predefinedScheme = "Monochrome";
            darkMode = true;
            schedulingMode = "off";
            syncGsettings = true;
          };

          notifications = {
            enabled = true;
            enableMarkdown = false;
            density = "default";
            location = "top_right";
            overlayLayer = true;
            respectExpireTimeout = false;
            lowUrgencyDuration = 3;
            normalUrgencyDuration = 8;
            criticalUrgencyDuration = 15;
            clearDismissed = true;
            saveToHistory = {
              low = true;
              normal = true;
              critical = true;
            };
            sounds.enabled = false;
            enableMediaToast = false;
            enableKeyboardLayoutToast = true;
            enableBatteryToast = true;
          };

          appLauncher = {
            enableClipboardHistory = true;
            autoPasteClipboard = false;
            enableClipPreview = true;
            clipboardWrapText = true;
            enableClipboardSmartIcons = true;
            enableClipboardChips = true;
            clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
            clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
            position = "center";
            sortByMostUsed = true;
            terminalCommand = "alacritty -e";
            viewMode = "list";
            showCategories = true;
            iconMode = "tabler";
            showIconBackground = false;
            enableSettingsSearch = true;
            enableWindowsSearch = true;
            enableSessionSearch = true;
            density = "default";
          };

          idle = {
            enabled = true;
            screenOffTimeout = 600;
            lockTimeout = 660;
            suspendTimeout = 1800;
            fadeDuration = 5;
          };

          nightLight = {
            enabled = false;
            forced = false;
            autoSchedule = true;
            nightTemp = "4000";
            dayTemp = "6500";
          };

          wallpaper = {
            enabled = true;
            overviewEnabled = false;
            fillMode = "crop";
            fillColor = "#000000";
            useSolidColor = false;
            solidColor = "#1a1a2e";
            automationEnabled = false;
            transitionDuration = 1500;
            skipStartupTransition = false;
            overviewBlur = 0.4;
            overviewTint = 0.6;
          };

          audio = {
            volumeStep = 5;
            volumeOverdrive = false;
            spectrumFrameRate = 30;
            visualizerType = "linear";
            spectrumMirrored = true;
            volumeFeedback = false;
          };

          brightness = {
            brightnessStep = 5;
            enforceMinimum = true;
            enableDdcSupport = false;
          };

          controlCenter = {
            position = "close_to_bar_button";
            diskPath = "/";
            shortcuts = {
              left = [
                {id = "Network";}
                {id = "Bluetooth";}
                {id = "WallpaperSelector";}
                {id = "NoctaliaPerformance";}
              ];
              right = [
                {id = "Notifications";}
                {id = "PowerProfile";}
                {id = "KeepAwake";}
                {id = "NightLight";}
              ];
            };
          };

          sessionMenu = {
            enableCountdown = true;
            countdownDuration = 10000;
            position = "center";
            showHeader = true;
            showKeybinds = true;
            largeButtonsStyle = true;
            largeButtonsLayout = "single-row";
          };

          systemMonitor = {
            cpuWarningThreshold = 80;
            cpuCriticalThreshold = 90;
            tempWarningThreshold = 80;
            tempCriticalThreshold = 90;
            memWarningThreshold = 80;
            memCriticalThreshold = 90;
            diskWarningThreshold = 80;
            diskCriticalThreshold = 90;
            batteryWarningThreshold = 20;
            batteryCriticalThreshold = 5;
          };

          location = {
            name = "";
            weatherEnabled = true;
            weatherShowEffects = true;
            useFahrenheit = false;
            use12hourFormat = false;
            showWeekNumberInCalendar = false;
            showCalendarEvents = true;
            showCalendarWeather = true;
            firstDayOfWeek = -1;
            autoLocate = true;
          };

          network = {
            bluetoothRssiPollingEnabled = false;
            bluetoothRssiPollIntervalMs = 60000;
            networkPanelView = "wifi";
            wifiDetailsViewMode = "grid";
            bluetoothDetailsViewMode = "grid";
            bluetoothHideUnnamedDevices = false;
            disableDiscoverability = false;
            bluetoothAutoConnect = true;
          };

          osd = {
            enabled = true;
            location = "top_right";
            autoHideMs = 2000;
            overlayLayer = true;
          };

          templates = {
            activeTemplates = [];
            enableUserTheming = false;
          };

          plugins = {
            autoUpdate = false;
            notifyUpdates = true;
            polkit-agent = {
              enable = true;
            };
          };

          desktopWidgets = {
            enabled = false;
            overviewEnabled = true;
            gridSnap = false;
            gridSnapScale = false;
          };

          ui = {
            tooltipsEnabled = true;
            scrollbarAlwaysVisible = true;
            boxBorderEnabled = false;
            translucentWidgets = false;
            panelsAttachedToBar = true;
            settingsPanelMode = "attached";
          };
        };
      };
    };
  };
}
