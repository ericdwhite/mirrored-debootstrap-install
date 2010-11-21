#
# Configuration
#
#   After editing this file run 'guest.bash' to setup the
#   environment used to create the guest.
#
#   U_RELEASE -- Ubuntu release, see: http://releases.ubuntu.com/
#   U_ARCH -- Ubuntu architecture: i386, amd64
#   U_MIRROR -- The Ubuntu mirror to download packages from.
#               See:
#                 Official Archive Mirrors for Ubuntu
#                 https://launchpad.net/ubuntu/+archivemirrors

#
# Note: this is the configuration tested.

# Ubuntu Release
U_RELEASE=maverick
export U_RELEASE

# Ubuntu Architecture
U_ARCH=i386
export U_ARCH

# Ubuntu Source Package Mirror
U_MIRROR="http://gb.archive.ubuntu.com/ubuntu"
export U_MIRROR

echo "Using Ubuntu"
echo "  Release      : $U_RELEASE"
echo "  Architecture : $U_ARCH"
echo "  Mirror       : $U_MIRROR"
echo

#
# Guest defaults for the host and network.
#
# These can be overriden when executing `guest.bash`.
#
#   See: `guest.bash --help`
#
DEFAULT_KVM_DOMAIN="example.com"
DEFAULT_KVM_HOSTNAME="vm-001"
DEFAULT_KVM_IP_STATIC=10.80.20.201
DEFAULT_KVM_IP_NETMASK=255.255.255.0
DEFAULT_KVM_IP_GATEWAY=10.80.20.1
DEFAULT_KVM_IP_NAMESERVER=10.80.20.10

#
# Disk Image Parameters units: MiB
#
# Note: Leave 1 MiB for the MBR, and specify sizes in whole MiB only.
#
export KVM_IMAGE_SIZE=2000
export KVM_IMAGE_BOOT=60
export KVM_IMAGE_ROOT=$(( $KVM_IMAGE_SIZE - $KVM_IMAGE_BOOT - 1 ))
export KVM_SWAP_IMAGE_SIZE=500

# This is a marker to ensure this file
# is only loaded once.
UB_CONFIGURED=true
export UB_CONFIGURED
