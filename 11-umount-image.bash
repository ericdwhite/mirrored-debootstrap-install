#!/bin/bash
#
# Unmounts an existing KVM Image
#
# Note: This script uses 'sudo'.
#
#
if [ -z UB_CONFIGURED ]; then
  lerror "Please execute 'guest.bash' to configure the environment first."
  false || die "UBE000"
fi

# Initialise some helpers
. ${UB_HOME}/functions.bash

(cd ${UB_HOME}
(cd ${U_RELEASE}-${U_ARCH}-bootstrap
    linfo "Unmounting the image."
    sync

    # There could be errors but when things are messed it is best try
    # and unwind everything and check the final mount status.

    echo "Capturing errors during unmount process." > ERRORS.txt
    linfo "Unmount vm /dev"
    sudo umount ${VM_ROOT}/dev 2>> ERRORS.txt

    linfo "Unmount vm /proc"
    sudo umount ${VM_ROOT}/proc 2>> ERRORS.txt

    linfo "Unmount vm /tmp/mirror"
    sudo umount ${VM_ROOT}/tmp/mirror 2>> ERRORS.txt

    linfo "Unmount vm /boot"
    sudo umount /dev/mapper/loop5p1 2>> ERRORS.txt

    linfo "Unmount vm /"
    sync
    sudo umount /dev/mapper/loop5p2 2>> ERRORS.txt

    linfo "Release the loop."
    sudo kpartx -d /dev/loop5  2>> ERRORS.txt
    sudo losetup -d /dev/loop5  2>> ERRORS.txt

    linfo "Checking for mount points containing: ${VM_ROOT}"
    cat ERRORS.txt
    mount -l | grep ${VM_ROOT} && die "UBE028"

    linfo "Unmounted."
 ))
