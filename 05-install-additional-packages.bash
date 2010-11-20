#!/bin/bash
#
# Installs Additional packages using the local mirror
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

(cd ${U_RELEASE}-${U_ARCH}-bootstrap
    linfo "Working in: ${U_RELEASE}-${U_ARCH}-bootstrap and VM: ${VM_ROOT}"

    # Unmount first in case this script is being run standalone.
    ${UB_HOME}/11-umount-image.bash || die
    ${UB_HOME}/10-mount-image.bash || die

    ADDITIONAL_PACKAGES=`cat ${UB_HOME}/additional.packages | grep -v '^#' | sort -u | tr '\n' ' '`
    linfo "Installing: $ADDITIONAL_PACKAGES"
    sudo env PKGS="$ADDITIONAL_PACKAGES" chroot ${VM_ROOT} \
	/bin/bash -c 'apt-get -y --force-yes install ${PKGS}' || die "UBE040"
    
    ${UB_HOME}/11-umount-image.bash || die
)