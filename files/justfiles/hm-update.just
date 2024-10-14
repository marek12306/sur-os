hm-path := "~/.config/home-manager"

# Update home-manager
[no-cd]
hm-update:
        pushd $hm-path
        nix flake update
        popd
        home-manager switch
