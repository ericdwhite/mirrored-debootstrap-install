#!/bin/bash
#
# Installs Ubuntu using the local mirror
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

    linfo "Installing via debootstrap"
    sudo debootstrap --arch=${U_ARCH} ${U_RELEASE} ${VM_ROOT} file://`pwd`/mirror || die "UBE032"

    # Remount everything to make mirror and /dev available in the chroot.
    linfo "Remounting after debootstrap install."
    mkdir -p ${VM_ROOT}/tmp/mirror || die
    ${UB_HOME}/11-umount-image.bash || die
    ${UB_HOME}/10-mount-image.bash || die

    linfo "Configure apt to use the mirror, and install packages."
    sudo cp ${VM_ROOT}/etc/apt/sources.list ${VM_ROOT}/etc/apt/sources.list.bak || die
    sudo chroot ${VM_ROOT} /bin/bash -c 'cat > /etc/apt/sources.list<<EOF
deb file:///tmp/mirror maverick main universe
deb file:///tmp/mirror maverick-updates main universe
deb file:///tmp/mirror maverick-security main universe
EOF' || die "UBE041"

    sudo sh -c 'cat > ${VM_ROOT}/etc/apt/apt.conf.d/99-vm-no-extras-please <<EOF
APT::Install-Recommends "false";
APT::Install-Suggest "false";
EOF' || die "UBE041"
    

    linfo "Installing aptitude."
    sudo chroot ${VM_ROOT} /bin/bash -c 'apt-get -y update' || die "UBE040"
    sudo chroot ${VM_ROOT} /bin/bash -c 'apt-get -y --force-yes install aptitude' || die "UBE040"


    # This could be made more generic by having the kernel specified
    # in a file along side of the top level additional.packages file.
    linfo "Installing kernel: linux-image-server"
    sudo chroot ${VM_ROOT} /bin/bash -c 'DEBIAN_FRONTEND=noninteractive \
        apt-get -y --force-yes install linux-image-server' || die "UBE42"

    ADDITIONAL_PACKAGES=`cat mirror/additional.packages | tr '\n' ' '`
    linfo "Installing: $ADDITIONAL_PACKAGES"
    sudo env PKGS="$ADDITIONAL_PACKAGES" chroot ${VM_ROOT} \
	/bin/bash -c 'apt-get -y --force-yes install ${PKGS}' || die "UBE040"
    
    ${UB_HOME}/11-umount-image.bash || die
)