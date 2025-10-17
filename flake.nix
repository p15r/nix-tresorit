# The dependencies of the `tresorit` binary have been discovered
# using:
# - `ldd -v <BINARY>`
# - `strace`
# - read metrics log:
#   `grep metrics_collector_impl.cpp $HOME/.local/share/tresorit/Logs/tresorit_core_*.log`
#
# Find nixpkgs that provide shared objects:
# - `nix-locate <SHARED OBJECT>` (run `nix-index` before)

{
  description = "Tresorit FHS environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs =
    inputs@{
      nixpkgs,
      ...
    }:
    let
      pname = "tresorit-fhs";
      supportedSystem = "x86_64-linux";
      pkgs = import nixpkgs {
        system = supportedSystem;
        config.allowUnfree = true;
      };
      tresorit_fhs = pkgs.buildFHSEnv {
        name = pname;

        targetPkgs = pkgs: with pkgs; [
          # "tresorit" binary
          qt5.qtbase
          libsForQt5.full # ldd: libGL.so.1
          fuse
          xorg.libxcb # ldd: libxcb-glx.so.0
                      # ldd: libxcb-shm.so.0
                      # ldd: libxcb-randr.so.0
                      # ldd: libxcb-render.so.0
                      # ldd: libxcb-shape.so.0
                      # ldd: libxcb-sync.so.1
                      # ldd: libxcb-xfixes.so.0
                      # ldd: libxcb-xkb.so.1
                      # ldd: libxcb.so.1
          xorg.libX11 # ldd: libX11-xcb.so.1
                      # ldd: libX11.so.6
          glibc # ldd: libdl.so.2
                # ldd: librt.so.1
                # ldd: libm.so.6
                # ldd: libpthread.so.0
                # ldd: libc.so.6
                # ldd: ld-linux-x86-64.so.2
          libgcc # ldd: libgcc_s.so.1
          pcre2
          libcap
          xorg.xcbutilwm # ldd: libxcb-icccm.so.4
          xorg.xcbutilimage # ldd: libxcb-image.so.0
          xorg.xcbutilkeysyms # ldd: libxcb-keysyms.so.1
          xorg.xcbutilrenderutil # ldd: libxcb-render-util.so.0
          libxkbcommon # ldd: libxkbcommon-x11.so.0
                       # ldd: libxkbcommon.so.0
          xorg.libXext # ldd: libXext.so.6
          xcb-util-cursor # metrics log: xcb-util-cursor
          xcbutilxrm # metrics log: xcbutilxrm
          libGLU
          libGL
          krb5 # metrics log: libgssapi_krb5.so.2

          # "tresorit-cli" binary
          # glibc # ldd: libdl.so.2
          #       # ldd: librt.so.1
          #       # ldd: libpthread.so.0
          #       # ldd: libm.so.6
          #       # ldd: libc.so.6
          #       # ldd: ld-linux-x86-64.so.2
          # libgcc # ldd: libgcc_s.so.1

          # "tresorit-daemon" binary
          # glibc # ldd: libdl.so.2
          #       # ldd: librt.so.1
          #       # ldd: libpthread.so.0
          #       # ldd: libm.so.6
          #       # ldd: libc.so.6
          #       # ldd: ld-linux-x86-64.so.2
          # libgcc # ldd: libgcc_s.so.1
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

      devShells = (
        let
          pkgs = import inputs.nixpkgs { system = supportedSystem; };
        in
        {
          ${supportedSystem} = {
            default = pkgs.mkShell {
              buildInputs = [
                pkgs.haskellPackages.cabal-install
                pkgs.ghc
                pkgs.deadnix
              ];
            };
          };
        }
      );
    };
}
