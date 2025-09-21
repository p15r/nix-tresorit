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
1. Create Tresorit FHS launcher script: `./create_launcher.sh` (requires `bash`)
1. Launch `Tresorit FHS` from your favorite app launcher and sign in.

Done 🎉.

<details>
<summary>Quick troubleshooting</summary>

- service status: `systemctl --user status app-tresorit\\x2dfhs@autostart.service`
- systemd logs: `journalctl --user -u app-tresorit\\x2dfhs@autostart.service`
- fhs logs: `$HOME/.local/share/tresorit/fhs.log`
</details>
