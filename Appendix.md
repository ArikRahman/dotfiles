## This is where commands are saved for future reference
do  ```git config --local credential.helper '!gh auth git-credential'``` to enable github cli authentication for git
do  ```sudo nixos-rebuild switch --flake .#hydenix ``` to update nixos
do  ```sudo chown -R hydenix:users /mnt/arik_s_disk/SteamLibrary/steamapps/compatdata``` to fix steam proton prefix ownership issues
- sometimes have to run ```sudo mount -o remount,exec /mnt/arik_s_disk``` to make games work again because drive mounts with noexec
do  ```nix flake update``` to update flake inputs
do  ```gh auth login``` to login to github cli
do  ```gh repo clone ArikRahman/hydenix``` to clone hydenix repo
do Optional: run ```nix flake update nixpkgs``` which will make Unstraightened reuse more dependencies already on your system.
- Validation (reproducible check after config changes): run ```nix flake check``` from the repo root
- dota 2 audio cuts out whenf inding match, fix with launch option ```-sdlaudiodriver pulse```
- had to use vscodium and delete existing .config git config file to override and git auth login would apply allowing cli git push to remote
