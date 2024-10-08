# https://github.com/apeyroux/tresorit.nix uses the patchelfhook to run on NixOS. This works until Tresorit autom. updates and then you are screwed, because you are no longer running the patched binaries.
# 
# So, the goal of this code is to create a FHS environment for Tresorit. I have a working environment so far, but Tresorit doesn't like to be executed outside of ~/.local/share/tresorit and w/o permission to self-update. Both conditions are not met within an FHS env, so the resulting FHS-based Tresorit exits w/ error: [18:35:22] ! /home/jenkins/jenkins/git/TresoritQt/Source/main.cpp:136: Another instance is running.. I do not know if it is possible to export the FHS isolated binaries from the FHS env into the local file system at ~/.local/share/tresorit.
# 
# Alternative, just containerize Tresorit.

# Misc commands
# $out: root directory of chroot, e.g. $out/bin is /bin in fhs env
# run: NIXPKGS_ALLOW_UNFREE=1 nix run --impure .#default
# build: NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#default (output in ./results/bin/tresorit)
# debug
# - flake: nix flake show
# - outpus: nix repl; :lf .; outputs.<TAB>

{
  description = "Tresorit in FHS environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
    }:
    let
      pname = "tresorit";
      version = "0.1.0";

      pkgs = import nixpkgs { system = "x86_64-linux"; };

      tresorit = pkgs.stdenv.mkDerivation {
        inherit pname version;

        src = builtins.fetchurl {
          url = "https://installerstorage.blob.core.windows.net/public/install/tresorit_installer.run";
          sha256 = "865bf2e54791546e9637823671ca5475091b6f8a2599c668040d3feed092b6ee";
        };

        dontBuild = true;
        dontConfigure = true;
        dontMake = true;
        dontWrapQtApps = true;

        unpackPhase = ''
          tail -n+93 $src | tar xz -C $TMP
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp -rf $TMP/tresorit_x64/* $out/bin/
          rm $out/bin/uninstall.sh
        '';
      };

      tresorit_fhs = pkgs.buildFHSEnv {
        name = pname;
        version = version;

        targetPkgs = pkgs: [
          tresorit
          pkgs.qt5.qtbase
          pkgs.fuse
          pkgs.xorg.libxcb
          pkgs.xorg.libX11
          pkgs.xorg.xcbutilwm # libxcb-icccm.so.4
          pkgs.xorg.xcbutilimage # libxcb-image.so.0
          pkgs.xorg.xcbutilkeysyms # libxcb-keysyms.so.1
          pkgs.xorg.xcbutilrenderutil # libxcb-render-util.so.0
          pkgs.libxkbcommon
          pkgs.xorg.libXext
          pkgs.libGLU
          pkgs.libGL
        ];

        # runScript = ''
        #   # debug the FHS environment...
        #   echo $HOME
        #   /bin/tresorit
        # '';
        runScript = pname;

        # where (mountPoint) inside the fhsenv do I have to mount the host path in order to have write access?
        # or should I "just make $out/bin writable?
        #extraBindMounts = [
        #  {
        #    hostPath = "$HOME/.local/share/";
        #    mountPoint = "$HOME/.local/share/";
        #  }
        #];

        meta = with pkgs.lib; {
          description = "Secure file synchronisation using Tresorit";
          homepage = "https://tresorit.com/";
          license = licenses.unfree;
          platforms = platforms.linux;
          maintainers = with maintainers; [ p15r ];
        };
      };
    in
    {
      packages.x86_64-linux.default = tresorit_fhs;
    };
}
