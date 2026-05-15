#!/bin/bash
mv /usr/lib/kernel/install.d/05-rpmostree.install /tmp/05-rpmostree.install.bak

rpm-ostree override remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra --install kernel-cachyos

KVER=$(ls /usr/lib/modules | grep cachyos)
depmod -a $KVER

mv /tmp/05-rpmostree.install.bak /usr/lib/kernel/install.d/05-rpmostree.install
