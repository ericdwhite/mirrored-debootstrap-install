#!/bin/bash
#
# This launches the guest using KVM, for testing.
#
if [ -z $UB_CONFIGURED ]; then
  echo "Please execute 'guest.bash' to configure the environment first."
  exit 1
fi

# Initialise some helpers
. ${UB_HOME}/functions.bash

(cd ${U_RELEASE}-${U_ARCH}-bootstrap
    linfo "Working in: ${U_RELEASE}-${U_ARCH}-bootstrap and VM: ${VM_ROOT}"

    ${UB_HOME}/11-umount-image.bash || die
    kvm -drive file=${DISK_IMAGE},index=0,media=disk \
	-drive file=${VM_SWAP_IMAGE},index=1,media=disk \
	-net tap,ifname=tap0,script=no,downscript=no -net nic \
	-m 256m
)
