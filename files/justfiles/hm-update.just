hmpath := "~/.config/home-manager"

# Update home-manager
[no-cd]
hm-update:
        pushd $hmpath
        nix flake update
        popd
        home-manager switch
