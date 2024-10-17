A Nix Flake that creates an FHS environment for Tresorit allowing it to be installed
from the [official source](https://tresorit.com/download) without the worry
about Tresorit being dynamically-linked and self-updating.

# Installation Steps
1. Install Tresorit (use default path suggested by installer!):
   ```bash
   curl \
     -fL -o tresorit_installer.run \
     https://installer.tresorit.com/tresorit_installer.run \
   && sh tresorit_installer.run && rm tresorit_installer.run
   ```
1. Build FHS env: `NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#default`
1. "Patch" Tresorit installation: `./patch.sh`
   - creates an FHS env-based Tresorit launcher for desktop environments
   - registers Tresorit launcher as autostart application
   - updates desktop environment (`.desktop`) files to respect FHS env

Testing:
- [x] Tresorit version on 15th of October 2024: 3.5.1244.4360
- [ ] did it successfully self-update and continues to run?
