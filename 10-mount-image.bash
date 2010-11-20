#!/bin/bash
#
# Mounts an existing KVM Image
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
    linfo "Mounting the image partitions."
    mkdir -p ${U_RELEASE}-${U_ARCH}-vm || die "UBE031"

    sudo losetup /dev/loop5 ${DISK_IMAGE} || die "UBE027"
    sudo kpartx -a /dev/loop5 || die "UBE027"
    sudo mount /dev/mapper/loop5p2 ${U_RELEASE}-${U_ARCH}-vm || die "UBE031"
    sudo mkdir -p ${VM_ROOT}/boot || die "UBE031"
    sudo mount /dev/mapper/loop5p1 ${U_RELEASE}-${U_ARCH}-vm/boot || die "UBE031"

    # Mount if necessary. If a partial install has occurred then these
    # directories will be available to mount.
    linfo "Make the /dev available in the chroot."
    mount -l | grep ${U_RELEASE} | grep '/dev ' | grep ${VM_ROOT}
    DEV_MOUNTED=$?
    if [ $DEV_MOUNTED -ne 0 ]; then
	if [ -d ${VM_ROOT}/dev ]; then
	    linfo "Binding /dev"
	    sudo mount --bind /dev ${VM_ROOT}/dev || die "UBE033"
	fi
    fi

    linfo "Make the /proc available in the chroot."
    mount -l | grep ${U_RELEASE} | grep '/proc ' | grep ${VM_ROOT}
    PROC_MOUNTED=$?
    if [ $PROC_MOUNTED -ne 0 ]; then
	if [ -d ${VM_ROOT}/dev ]; then
	    linfo "Binding /proc"
	    sudo mount --bind /proc ${VM_ROOT}/proc || die "UBE033"
	fi
    fi

    mount -l | grep ${U_RELEASE} | grep '/tmp/mirror ' | grep ${VM_ROOT}
    MIRROR_MOUNTED=$?
    if [ $MIRROR_MOUNTED -ne 0 ]; then
	if [ -d ${VM_ROOT}/tmp/mirror ]; then
            linfo "Binding /tmp/mirror"
	    sudo mount --bind mirror ${VM_ROOT}/tmp/mirror || die "UBE033"
	fi
    fi

    linfo "Finding mounts containing: ${VM_ROOT}"
    mount -l | grep ${VM_ROOT} || die "UBE028"
))
