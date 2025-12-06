# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Required for a proper graphical environment
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  boot.supportedFilesystems = [ "nfs" ];
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "sg" "fuse" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr          # ROCm OpenCL runtime
      rocmPackages.rocminfo     # for checking GPU compute
      rocmPackages.rocm-smi     # system management interface
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
      mesa-demos
      libva-utils
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "adaptive";  # or "flat"picard
      accelSpeed = "1.0";         # must be quoted
    };
  };

  services.displayManager.sddm.settings = {
    General = {
      DisplayServer = "wayland";
      GreeterEnvironment = "QT_QPA_PLATFORM=wayland";
    };
    Wayland = {
      EnableVT = true;
    };
  };



  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };


  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;

      extraConfig = {
        "99-bluetooth-policy" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-hsp" = false;
            "bluez5.enable-hfp" = false;
            "bluez5.enable-msbc" = false;

            "bluez5.enable-aac" = true;
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-ldac" = true;
          };
        };
      };
    };

  };



  users.users.gandalf = {
    isNormalUser = true;
    description = "gandalf";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "dialout"];
    packages = with pkgs; [
      kdePackages.kate
      keepassxc 
    #  thunderbird
    ];
  };

  services.udev.extraRules = ''
    # Disable BAD adapter (hci1) only if it exists
    ACTION=="add", SUBSYSTEM=="bluetooth", KERNEL=="hci1", \
      RUN+="/bin/sh -c 'test -e /sys/class/bluetooth/hci1 && ${pkgs.bluez}/bin/btmgmt --index 1 power off'"

    # Enable GOOD adapter (hci0) only if it exists
    ACTION=="add", SUBSYSTEM=="bluetooth", KERNEL=="hci0", \
      RUN+="/bin/sh -c 'test -e /sys/class/bluetooth/hci0 && ${pkgs.bluez}/bin/btmgmt --index 0 power on'"
  '';


  systemd.user.services.nextcloud-client = {
    description = "Nextcloud desktop sync client";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud";
      Restart = "on-failure";
    };
  };

  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.mullvad-vpn.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fuse
    appimage-run
    orca-slicer
    thonny
    #rust
    rustup         # installer and toolchain manager
    cargo          # Rust package manager
    rustc          # compiler (if you prefer a static toolchain)
    pkg-config     # needed for many crates with native deps
    openssl        # common dependency
    cmake          # for building native libs
    clang          # for crates using bindgen
    #rust end
    abcde
    picard
    wine       # 32-bit support included if you enable multilib
    wineWowPackages.stableFull  # good all-rounder for gaming
    winetricks
    lutris
    calibre
    kdePackages.filelight
    pciutils
    usbutils
    lm_sensors
    nvme-cli
    vim
    wget
    git
    openssh
    libnotify
    nodejs_22
    yarn
    python3
    pkg-config
    gcc
    gnumake
    nextcloud-client
    vscode
    mullvad
    mullvad-vpn
    nfs-utils
    transmission_4-gtk
    slack
    teams-for-linux
    steam
    gitkraken
    heroic
    code-cursor
    gpodder
    libreoffice
    jq
    chromium
    pkgs.mpv
    vlc
    neofetch
    makemkv
    qalculate-gtk
    signal-desktop
    emacs
    gparted
    udisks2
    popsicle

    spice-vdagent
    # Salesforce CLI via flake
    (builtins.getFlake "github:rfaulhaber/sfdx-nix").packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.verbatimConfig = ''
      # ensure KVM acceleration
    '';
  };

  programs.virt-manager.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;   # optional, for streaming from/to this box
    dedicatedServer.openFirewall = true; # optional, if you host anything
  };


  fileSystems."/mnt/tv" = {
    device = "192.168.68.76:/mnt/tank/media/tv";
    fsType = "nfs";
      options = [
        "nfsvers=4"
        "proto=tcp"
        "_netdev"
        "noatime"
        "x-systemd.automount"
        "noauto"
      ];
  };

  fileSystems."/mnt/movies" = {
    device = "192.168.68.76:/mnt/tank/media/movies";
    fsType = "nfs";
      options = [
        "nfsvers=4"
        "proto=tcp"
        "_netdev"
        "noatime"
        "x-systemd.automount"
        "noauto"
      ];
  };

  fileSystems."/mnt/music" = {
    device = "192.168.68.76:/mnt/tank/media/music";
    fsType = "nfs";
      options = [
        "nfsvers=4"
        "proto=tcp"
        "_netdev"
        "noatime"
        "x-systemd.automount"
        "noauto"
      ];
  };

  fileSystems."/mnt/tank" = {
    device = "192.168.68.76:/mnt/tank";
    fsType = "nfs";
      options = [
        "nfsvers=4"
        "proto=tcp"
        "_netdev"
        "noatime"
        "x-systemd.automount"
        "noauto"
      ];
  };

  fileSystems."/mnt/books" = {
    device = "192.168.68.76:/mnt/tank/media/books";
    fsType = "nfs";
      options = [
        "nfsvers=4"
        "proto=tcp"
        "_netdev"
        "noatime"
        "x-systemd.automount"
        "noauto"
      ];
  };

  fileSystems."/mnt/games" = {
    device = "192.168.68.76:/mnt/tank/media/games";
    fsType = "nfs";
      options = [
        "nfsvers=4"
        "proto=tcp"
        "_netdev"
        "noatime"
        "x-systemd.automount"
        "noauto"
      ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
