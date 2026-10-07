#!/usr/bin/env bash
set -xe 
dnf copr enable ublue-os/packages
REPO="copr:copr.fedorainfracloud.org:ublue-os:packages"
sudo dnf config-manager disable "$REPO"
dnf --enablerepo="$REPO" install gnome-rounded-blur
