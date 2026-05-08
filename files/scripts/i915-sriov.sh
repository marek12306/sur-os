#!/bin/bash
set -ouex pipefail

echo "=== i915-sriov ==="

dnf install -y --setopt=tsflags=noscripts akmod-i915-sriov

mkdir -p /tmp/akmods-build
cp /usr/src/akmods/i915-sriov-kmod*.src.rpm /tmp/akmods-build/
chown -R akmods:akmods /tmp/akmods-build

KERNEL_VERSION=$(ls /lib/modules | grep -E '^[0-9]\.' | head -n 1)

su -s /bin/bash akmods -c "akmodsbuild --kernels ${KERNEL_VERSION} /tmp/akmods-build/i915-sriov-kmod*.src.rpm"

dnf install -y /tmp/akmods-build/*.rpm

echo "=== i915-sriov done ==="

