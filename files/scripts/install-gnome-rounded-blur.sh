#!/usr/bin/env bash
set -xe 
dnf copr enable ublue-os/packages
dnf copr disable ublue-os/packages
REPO="copr:copr.fedorainfracloud.org:ublue-os:packages"
dnf install --enable-repo="$REPO" gnome-rounded-blur
