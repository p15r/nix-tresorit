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
      pname = "tresorit-fhs";
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      tresorit_fhs = pkgs.buildFHSEnv {
        name = pname;

        targetPkgs = pkgs: [
          pkgs.qt5.qtbase
          pkgs.fuse
          pkgs.xorg.libxcb
          pkgs.xorg.libX11
          pkgs.glibc
          pkgs.pcre2
          pkgs.libcap
          pkgs.xorg.xcbutilwm # libxcb-icccm.so.4
          pkgs.xorg.xcbutilimage # libxcb-image.so.0
          pkgs.xorg.xcbutilkeysyms # libxcb-keysyms.so.1
          pkgs.xorg.xcbutilrenderutil # libxcb-render-util.so.0
          pkgs.libxkbcommon
          pkgs.xorg.libXext
          pkgs.libGLU
          pkgs.libGL
        ];
        runScript = "bash";
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
