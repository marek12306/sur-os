#!/bin/bash
set -ouex pipefail

dnf install -y akmods sysfsutils rpm-build rpmdevtools kmodtool dnf-plugins-core jq curl

dnf copr enable -y sihawken/akmod-i915-sriov

mkdir -p /tmp/sriov-source && cd /tmp/sriov-source
dnf download --source akmod-i915-sriov

rpm -ivh *.src.rpm

rm -f /root/rpmbuild/SOURCES/*.tar.gz

LATEST_COMMIT=$(curl -s https://api.github.com/repos/strongtz/i915-sriov-dkms/commits/master | jq -r .sha)
SHORT_COMMIT=${LATEST_COMMIT:0:7}

sed -i "s/%global commit .*/%global commit $LATEST_COMMIT/" /root/rpmbuild/SPECS/*.spec
sed -i "s/%global shortcommit .*/%global shortcommit $SHORT_COMMIT/" /root/rpmbuild/SPECS/*.spec

spectool -g -R /root/rpmbuild/SPECS/*.spec
rpmbuild -ba /root/rpmbuild/SPECS/*.spec

dnf install -y /root/rpmbuild/RPMS/*/*.rpm --setopt=tsflags=noscripts

mkdir -p /tmp/akmods-build
cp /root/rpmbuild/SRPMS/*.src.rpm /tmp/akmods-build/
chown -R akmods:akmods /tmp/akmods-build

KERNEL_VERSION=$(ls /lib/modules | grep -E '^[0-9]\.' | head -n 1)

cd /tmp/akmods-build
su -s /bin/bash akmods -c "akmodsbuild --kernels ${KERNEL_VERSION} /tmp/akmods-build/*.src.rpm"

dnf install -y /tmp/akmods-build/*.rpm --setopt=tsflags=noscripts

