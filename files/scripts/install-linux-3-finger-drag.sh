#!/usr/bin/env bash
set -ouex pipefail

echo "Installing linux-3-finger-drag..."

# Install build dependencies
dnf install -y cargo rust git gcc libinput-devel

git clone https://github.com/R3-da/linux-3-finger-drag.git -b "fix/accumulate-subpixel-motion" /tmp/linux-3-finger-drag
cd /tmp/linux-3-finger-drag

cargo build --release

# Install binary
cp ./target/release/linux-3-finger-drag /usr/bin/

# Configure uinput
mkdir -p /usr/lib/modules-load.d
echo "uinput" > /usr/lib/modules-load.d/uinput.conf

# Install the provided uinput udev rule
mkdir -p /usr/lib/udev/rules.d
cp ./60-uinput.rules /usr/lib/udev/rules.d/

# Provide uaccess to touchpads so the program can read from them without the user being in the 'input' group.
echo 'SUBSYSTEM=="input", ENV{ID_INPUT_TOUCHPAD}=="1", TAG+="uaccess"' > /usr/lib/udev/rules.d/61-touchpad-uaccess.rules

# Install default configuration template
mkdir -p /usr/share/linux-3-finger-drag
cp ./3fd-config.json /usr/share/linux-3-finger-drag/

# Install systemd user service
mkdir -p /usr/lib/systemd/user
sed -i '/^ExecStart=/i ExecStartPre=/bin/sh -c "mkdir -p %h/.config/linux-3-finger-drag; [ -f %h/.config/linux-3-finger-drag/3fd-config.json ] || cp /usr/share/linux-3-finger-drag/3fd-config.json %h/.config/linux-3-finger-drag/3fd-config.json"' three-finger-drag.service
cp three-finger-drag.service /usr/lib/systemd/user/
systemctl --global enable three-finger-drag.service

# Clean up
dnf remove -y cargo rust
rm -rf /tmp/linux-3-finger-drag

echo "linux-3-finger-drag installed successfully."
