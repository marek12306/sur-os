#!/usr/bin/env bash
set -xe 
dnf -y copr enable ublue-os/packages
dnf -y copr disable ublue-os/packages
REPO="copr:copr.fedorainfracloud.org:ublue-os:packages"
dnf -y install --enable-repo="$REPO" gnome-rounded-blur
