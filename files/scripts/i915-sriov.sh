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
rpmbuild -bs /root/rpmbuild/SPECS/*.spec

cat << EOF > /root/rpmbuild/SPECS/dummy-common.spec
Name: i915-sriov-kmod-common
Epoch: 1
Version: 99.99
Release: 1
Summary: Dummy common package to bypass dependencies
License: MIT
BuildArch: noarch
Provides: i915-sriov-kmod-common >= 0

%description
Dummy package generated dynamically to bypass strict kmodtool requirements.

%files
EOF

rpmbuild -bb /root/rpmbuild/SPECS/dummy-common.spec

mkdir -p /tmp/akmods-build
cp /root/rpmbuild/SRPMS/i915*.src.rpm /tmp/akmods-build/
chown -R akmods:akmods /tmp/akmods-build

KERNEL_VERSION=$(ls /lib/modules | grep -E '^[0-9]\.' | head -n 1)

cd /tmp/akmods-build
su -s /bin/bash akmods -c "akmodsbuild --kernels ${KERNEL_VERSION} /tmp/akmods-build/*.src.rpm"

dnf install -y /root/rpmbuild/RPMS/noarch/i915-sriov-kmod-common*.rpm /tmp/akmods-build/kmod-i915-sriov-*.rpm --setopt=tsflags=noscripts

