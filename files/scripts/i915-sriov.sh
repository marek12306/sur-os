#!/bin/bash
set -ouex pipefail

dnf install -y rpm-build rpmdevtools git curl jq kmodtool

mkdir -p /root/rpmbuild/{SOURCES,SPECS}
git clone https://github.com/matte23/akmod-i915-sriov.git /tmp/akmod-pkg
cp /tmp/akmod-pkg/* /root/rpmbuild/SOURCES/
mv /root/rpmbuild/SOURCES/i915-sriov.spec /root/rpmbuild/SPECS/

LATEST_COMMIT=$(curl -s https://api.github.com/repos/strongtz/i915-sriov-dkms/commits/master | jq -r .sha)

sed -i "s/%global commit .*/%global commit $LATEST_COMMIT/" /root/rpmbuild/SPECS/i915-sriov.spec

spectool -g -R /root/rpmbuild/SPECS/i915-sriov.spec
rpmbuild -ba /root/rpmbuild/SPECS/i915-sriov.spec

dnf install -y /root/rpmbuild/RPMS/x86_64/i915-sriov-*.rpm /root/rpmbuild/RPMS/x86_64/akmod-i915-sriov-*.rpm --setopt=tsflags=noscripts

mkdir -p /tmp/akmods-build
cp /root/rpmbuild/SRPMS/*.src.rpm /tmp/akmods-build/
chown -R akmods:akmods /tmp/akmods-build

KERNEL_VERSION=$(ls /lib/modules | grep -E '^[0-9]\.' | head -n 1)

cd /tmp/akmods-build
su -s /bin/bash akmods -c "akmodsbuild --kernels ${KERNEL_VERSION} /tmp/akmods-build/*.src.rpm"

dnf install -y /tmp/akmods-build/*.rpm
