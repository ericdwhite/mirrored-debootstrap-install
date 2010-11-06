#!/bin/bash
#
# Create a KVM disk image to install into.
#
# Note: This script uses 'sudo'.
#
# The Ubuntu disk sizes are set in:
#   config.sh
#
if [ -z UB_CONFIGURED ]; then
  lerror "Please execute 'guest.bash' to configure the environment first."
  false || die "UBE000"
fi

# Initialise some helpers
. ${UB_HOME}/functions.bash

(cd ${U_RELEASE}-${U_ARCH}-bootstrap
    linfo "Working in: ${U_RELEASE}-${U_ARCH}-bootstrap"

    linfo "Creating ${DISK_IMAGE}"
    dd if=/dev/zero of=${DISK_IMAGE} bs=512 count=$((${KVM_IMAGE_SIZE}*1024*1024/512)) || die "UBE021"

    parted -s ${DISK_IMAGE} mklabel msdos || die "UBE022"

    DISK_PART_SIZE_BOOT=$(( ${KVM_IMAGE_BOOT}*1024*1024/512 ))
    DISK_PART_SIZE_ROOT=$(( ${KVM_IMAGE_ROOT}*1024*1024/512 ))
    linfo "Creating boot partition of size: ${DISK_PART_SIZE_BOOT}"
    parted ${DISK_IMAGE} unit s mkpart primary \
        2048 $(( 2048+${DISK_PART_SIZE_BOOT}-1 )) || die "UBE023"
    linfo "Creating root partition of size: ${DISK_PART_SIZE_ROOT}"
    parted ${DISK_IMAGE} unit s mkpart primary \
        $(( 2048+${DISK_PART_SIZE_BOOT} )) $(( 2048+${DISK_PART_SIZE_BOOT}+${DISK_PART_SIZE_ROOT}-1 )) || die "UBE024"

    linfo "Toggle the boot flag on"
    parted ubuntu-maverick-amd64.img set 1 boot on || die "UBE025"
    
    linfo "Image layout in 512B sectors."
    parted ${DISK_IMAGE} unit s print || die "UBE026"

    linfo "Image layout in Bytes."
    parted ${DISK_IMAGE} unit B print || die "UBE026"

    sudo losetup /dev/loop5 ${DISK_IMAGE} || die "UBE027"
    sudo kpartx -l /dev/loop5 || die "UBE027"
    sudo kpartx -a /dev/loop5 || die "UBE027"

    linfo "Formatting boot partition."
    sudo mkfs.ext2 -m 0 /dev/mapper/loop5p1 || die "UBE029"
    sudo tune2fs /dev/mapper/loop5p1 -L 'boot' || die "UBE029"
    
    linfo "Formatting root partition."
    sudo mkfs.ext3 /dev/mapper/loop5p2 || die "UBE030"
    sudo tune2fs /dev/mapper/loop5p2 -L 'root' || die "UBE030"

    ${UB_HOME}/11-umount-image.bash || die
)
