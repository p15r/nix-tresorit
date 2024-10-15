An FHSEnv-based Nix package for Tresorit.

Use https://github.com/p15r/tresorit.nix/tree/feat/tresorit-3.5.1241.4340 for the time being - or the upstream package if my
PR (https://github.com/apeyroux/tresorit.nix/pull/4) got merged.

Installation:
- `curl -fL -o tresorit_installer.run https://installerstorage.blob.core.windows.net/public/install/tresorit_installer.run && sh tresorit_installer.run && rm tresorit_installer.run`
- `NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#default`
- `./result/bin/tresorit-fhs`
- `nohup $HOME/.local/share/tresorit/tresorit &`

Testing:
- Tresorit version on 15th of October 2024: 3.5.1244.4360
- did it successfully self-update and continues to run?

Todo:
- How can the tresorit-fhs be built and stored globally, so I do not always have to `cd` into the repo, build and load the fhs bash? Create alias that points to /nix/store/tresorit-fhs-XXXX? Or save this path in $HOME/.local/tresorit/fhs and then create a shell script that autom. loads that fhs and runs tresorit?
