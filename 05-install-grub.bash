#!/bin/bash
#
# Install a Grub boot loader into the image.
#
# Note: This script uses 'sudo'.
#
if [ -z $UB_CONFIGURED ]; then
  echo "Please execute 'guest.bash' to configure the environment first."
  exit 1
fi

# Initialise some helpers
. ${UB_HOME}/functions.bash

(cd ${U_RELEASE}-${U_ARCH}-bootstrap
    linfo "Working in: ${U_RELEASE}-${U_ARCH}-bootstrap and VM: ${VM_ROOT}"

    # Unmount first in case this script is being run standalone.
    ${UB_HOME}/11-umount-image.bash || die
    ${UB_HOME}/10-mount-image.bash || die

    KVM_INITRD=`(cd ${VM_ROOT}/boot && ls init*)`
    KVM_KERNEL=`(cd ${VM_ROOT}/boot && ls vmlinuz*)`

    linfo "Installing grub with kernel: ${KVM_KERNEL}"
    sudo env KVM_KERNEL=$KVM_KERNEL KVM_INITRD=$KVM_INITRD \
             U_RELEASE=$U_RELEASE U_ARCH=$U_ARCH \
             sh -c 'cat > ${VM_ROOT}/boot/grub/menu.lst<<EOF
default 0
timeout 5
title Ubuntu ${U_RELEASE}-${U_ARCH}
root (hd0,0)
kernel /${KVM_KERNEL} root=LABEL=root ro
initrd /${KVM_INITRD}
EOF' || die "UBE060" "Failed to create /boot/grub/menu.lst"
    cat ${VM_ROOT}/boot/grub/menu.lst || die "UBE060"

    linfo "Installing grub binaries."
    sudo chroot ${VM_ROOT} /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get \
                   -y --force-yes install grub' || die "UBE040" "Apt install of grub failed."

    # This most likely needs to be changed for x386 architecture.
    sudo cp ${VM_ROOT}/usr/lib/grub/x86_64-pc/stage1 ${VM_ROOT}/boot/grub/ || die "UBE060"
    sudo cp ${VM_ROOT}/usr/lib/grub/x86_64-pc/stage2 ${VM_ROOT}/boot/grub/ || die "UBE060"
    sudo cp ${VM_ROOT}/usr/lib/grub/x86_64-pc/e2fs_stage1_5 ${VM_ROOT}/boot/grub/ || die "UBE060"


    ${UB_HOME}/11-umount-image.bash || die
)