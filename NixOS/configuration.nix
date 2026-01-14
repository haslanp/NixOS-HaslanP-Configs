{ config, pkgs,inputs,  ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  ################################
  # Nvidia Stable and Prime Offload
  ################################
    hardware.graphics.enable = true;

    services.xserver.enable = true;
    services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

    hardware.nvidia = {
        modesetting.enable = true;

        powerManagement.enable = false;
        powerManagement.finegrained = true;

        open = true;
        nvidiaSettings = true;

        package = config.boot.kernelPackages.nvidiaPackages.stable;

        prime = {
            offload = {
            enable = true;
            enableOffloadCmd = true;
            };

            #Correct Bus IDs (from your lshw output)
            amdgpuBusId = "PCI:5:0:0";
            nvidiaBusId = "PCI:1:0:0";
        };
    };

  ################################
  # Cleanup and Optimizations
  ################################
  boot.loader.grub.configurationLimit = 10;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;

  ################################
  # Zram
  ################################
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 200;
    priority = 100;
  };

  ################################
  # Bootloader (UEFI + GRUB)
  ################################
  boot.loader.systemd-boot.enable = false;

  boot.loader.efi = {
    canTouchEfiVariables = true;
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };

  boot.loader.timeout = 5;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  ################################
  # Networking
  ################################
  networking.hostName = "haslanixos";
  networking.networkmanager.enable = true;

  # Declarative DNS doesn't work with networkmanager
  # Use nmcli connection modify "<conn-name>" ipv4.dns "1.1.1.1 1.0.0.1"
  networking.nameservers = [ ];

  services.resolved.enable = false;

  ################################
  # Locale / Time
  ################################
  time.timeZone = "Europe/Istanbul";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  ################################
  # Desktop Environment
  ################################
  services = {
    desktopManager.plasma6.enable = false;
  # programs.hyprland.enable = true;
    displayManager.sddm = {
      enable = true;

    #  theme = "catppuccin-mocha-mauve";
      wayland.enable = true;
    };
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
  konsole
  elisa
  ];


  services.xserver.xkb = {
    layout = "tr";
    variant = "";
  };

  console.keyMap = "trq";

  ################################
  # Audio (PipeWire)
  ################################
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ################################
  # Printing and Bluetooth
  ################################

  services.printing.enable = true;

  hardware.bluetooth.enable = true;

  ################################
  # User
  ################################

# nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.haslanp = {
    isNormalUser = true;
    description = "HaslanP";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      floorp-bin
      kitty
      jamesdsp
      dopamine
      obsidian
      lshw #GPU BusID lookup
      vesktop
      telegram-desktop
      #inputs.zen.packages."${system}".default
      neovim
      nerd-fonts.zed-mono
      bluetui
      yt-dlp
      mpv
      vlc
      mpc-qt
      qbittorrent
    # p7zip
      p7zip-rar
      ffmpeg
    ];
  };

  ################################
  # Nix
  ################################

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    fastfetch
    btop
    tree

  ];

  ################################
  # System
  ################################

  system.stateVersion = "26.05";

  fileSystems."/mnt/LaptopHDD" = {
	device = "/dev/disk/by-uuid/36c26a51-9287-4891-8e29-ee610f7f88d7";
	fsType = "ext4";
	options = [ "nofail" "x-systemd.automount" ];
  };
}
