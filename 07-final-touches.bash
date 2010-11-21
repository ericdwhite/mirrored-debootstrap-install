#!/bin/bash
#
# This is the last step before booting the VM.  It reverts some
# chagnes made to the VM and sets the root password.
#
# This script is only intended to be run once.
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

    linfo "Reverting the apt sources changes"
    cat ${UB_HOME}/source.list.template | awk '{gsub("{{MIRROR}}", "'${U_MIRROR}'");print}' > tmp/source.list.live
    sudo cp tmp/source.list.live ${VM_ROOT}/etc/apt/sources.list.live || die
    sudo cp ${VM_ROOT}/etc/apt/sources.list.live ${VM_ROOT}/etc/apt/sources.list || die

    ${UB_HOME}/11-umount-image.bash || die
)
