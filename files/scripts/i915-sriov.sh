#!/bin/bash
set -ouex pipefail

dnf install -y akmods sysfsutils rpm-build rpmdevtools curl jq kmodtool dnf-plugins-core

dnf copr enable -y sihawken/akmod-i915-sriov

mkdir -p /tmp/sriov-source && cd /tmp/sriov-source
dnf download --source akmod-i915-sriov

rpm -ivh *.src.rpm

LATEST_COMMIT=$(curl -s https://api.github.com/repos/strongtz/i915-sriov-dkms/commits/master | jq -r .sha)

sed -i "s/%global commit .*/%global commit $LATEST_COMMIT/" /root/rpmbuild/SPECS/*.spec

spectool -g -R /root/rpmbuild/SPECS/*.spec

rpmbuild -ba /root/rpmbuild/SPECS/*.spec

dnf install -y /root/rpmbuild/RPMS/x86_64/i915-sriov-*.rpm /root/rpmbuild/RPMS/x86_64/akmod-i915-sriov-*.rpm --setopt=tsflags=noscripts

mkdir -p /tmp/akmods-build
cp /root/rpmbuild/SRPMS/*.src.rpm /tmp/akmods-build/
chown -R akmods:akmods /tmp/akmods-build

KERNEL_VERSION=$(ls /lib/modules | grep -E '^[0-9]\.' | head -n 1)

cd /tmp/akmods-build
su -s /bin/bash akmods -c "akmodsbuild --kernels ${KERNEL_VERSION} /tmp/akmods-build/*.src.rpm"
dnf install -y /tmp/akmods-build/*.rpm

