A Nix Flake that creates an FHS environment for Tresorit. This allows Tresorit
to be installed from the [official source](https://tresorit.com/download)
without the worry about it being a dynamically-linked, self-updating binary.

# Installation Steps
1. Install Tresorit (use default path (`$HOME/.local/share/tresorit`) suggested by the installer!):
   ```bash
   curl \
     -fL -o tresorit_installer.run \
     https://installer.tresorit.com/tresorit_installer.run \
   && sh tresorit_installer.run && rm tresorit_installer.run
   ```
1. Build FHS env: `NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#default`
1. Patch Tresorit .desktop files: `./patch.sh`
<details>
  <summary>details on patching</summary>

  - creates an FHS env-based Tresorit launcher for desktop environments
  - registers Tresorit launcher as autostart application
  - updates desktop environment (.desktop) files to respect FHS env
</details>

Done 🎉.
