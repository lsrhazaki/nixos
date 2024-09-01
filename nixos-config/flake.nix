{
  description = "Flake of nixsaiga";

  outputs = inputs@{ self, ... }:
    let
      # ---- SYSTEM SETTINGS ---- #
      systemSettings = {
        system = "x86_64-linux"; # system arch
        hostname = "nixsaiga"; # hostname
        profile = "personal"; # select a profile defined from my profiles directory
        timezone = "Asia/Manila"; # select timezone
        locale = "en_PH.UTF-8"; # select locale
      };

      # ----- USER SETTINGS ----- #
      userSettings = rec {
        username = "hazaki"; # username
        name = "hazaki"; # name/identifier
        dotfilesDir = "~/.dotfiles"; # absolute path of the local repo
        theme = "gruvbox-dark-medium"; # selcted theme from my themes directory (./themes/)
        wm = "leftwm"; # Selected window manager or desktop environment; must select one in both ./user/wm/ and ./system/wm/
        # window manager type (hyprland or x11) translator
        wmType = if ((wm == "hyprland") || (wm == "leftwm")) then "wayland" else "x11";
        browser = "firefox"; # Default browser; must select one from ./user/app/browser/
        defaultRoamDir = "Personal"; # Default org roam directory relative to ~/Org
        term = "kitty"; # Default terminal command;
        font = "Intel One Mono"; # Selected font
        fontPkg = pkgs.intel-one-mono; # Font package
      };

    lib = nixpkgs.lib;

      pkgs-stable = import inputs.nixpkgs-stable {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };

      pkgs-unstable = import inputs.nixpkgs-patched {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
       
    in {

    nixosConfigurations = {
      nixsaiga = lib.nixosSystem {
          inherit system;
          modules = [ (./. + "/profile" + ("/" +profile) + "/configuration.nix") ];
          specialArgs = {
          inherit systemSettings;
          inherit inputs;
          inherit pkgs-stable;
       };
     };
   };

    homeConfigurations = {
     user = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ (./. + "/profile" + ("/" +profile) + "/home.nix") ];
      extraSpecialArgs = {
          inherit pkgs-stable;
          inherit usersettings;
          inherit inputs;
     };
  };
};

   inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"

    stylix.url = "github:danth/stylix";
   };

}
