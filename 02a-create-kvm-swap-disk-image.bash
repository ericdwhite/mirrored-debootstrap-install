#!/bin/bash
#
# Create a KVM swap disk image.
#
# Note: This script uses 'sudo'.
#
# The Ubuntu disk sizes are set in:
#   config.sh
#
if [ -z $UB_CONFIGURED ]; then
  echo "Please execute 'guest.bash' to configure the environment first."
  exit 1
fi

# Initialise some helpers
. ${UB_HOME}/functions.bash

(cd ${U_RELEASE}-${U_ARCH}-bootstrap || die
    linfo "Working in: ${U_RELEASE}-${U_ARCH}-bootstrap"

    linfo "Creating ${VM_SWAP_IMAGE}"
    dd if=/dev/zero of=${VM_SWAP_IMAGE} bs=512 count=$((${KVM_SWAP_IMAGE_SIZE}*1024*1024/512)) || die "UBE021a"

    parted -s ${VM_SWAP_IMAGE} mklabel msdos || die "UBE022"

    linfo "Creating swap partition"
    parted ${VM_SWAP_IMAGE} unit s mkpart primary \
        2048 $(( (${KVM_SWAP_IMAGE_SIZE}*1024*1024/512) - 1 )) || die "UBE023"

    linfo "Image layout in 512B sectors."
    parted ${VM_SWAP_IMAGE} unit s print || die "UBE026"

    linfo "Image layout in Bytes."
    parted ${VM_SWAP_IMAGE} unit B print || die "UBE026"

    sudo losetup /dev/loop6 ${VM_SWAP_IMAGE} || die "UBE027"
    sudo kpartx -l /dev/loop6 || die "UBE027"
    sudo kpartx -a /dev/loop6 || die "UBE027"

    linfo "Formatting boot partition."
    sudo mkswap -L 'swap' /dev/mapper/loop6p1 || die "UBE029"
    
    sudo kpartx -d /dev/loop6 || die
    sudo losetup -d /dev/loop6 || die
)
