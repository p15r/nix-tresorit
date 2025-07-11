# https://github.com/apeyroux/tresorit.nix uses the patchelfhook to run Tresorit on NixOS.
# This fails after Tresorit autoupdates itself as the updated binary is no longer patched.
# The dependencies of the `tresorit` binary have been discovered 
# using `ldd` & `strace`.
# 
# Alternatively, containerize Tresorit...

# debug this flake:
# - flake: `nix flake show`
# - outputs: `nix repl; :lf .; outputs.<TAB>`

{
  description = "Tresorit in FHS environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
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
          # `tresorit` binary
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
          # `tresorit-cli` binary
          # to be done
          # `tresorit-daemon` binary
          # to be done
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
