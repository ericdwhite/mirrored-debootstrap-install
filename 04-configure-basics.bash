#!/bin/bash
#
# Configures the basic environment of the VM:
#  fstab, network, hosts, etc
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

    linfo "Setting the root password."
    sudo chroot ${VM_ROOT} /bin/bash -c 'echo "root:gotcha12" | chpasswd' || die

    linfo "Creating /etc/fstab"
    sudo chroot ${VM_ROOT} /bin/bash -c 'cat > /etc/fstab<<EOF
# /etc/fstab: static file system information.
#
# Use vol_id --uuid to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>                  <dump>  <pass>
proc            /proc           proc    defaults                   0       0
LABEL=boot      /boot           ext2    relatime                   0       2
LABEL=root      /               ext3    relatime,errors=remount-ro 0       1
LABEL=swap      swap            swap    pri=42                     0       0
EOF' || die "UBE50" "Failed to create /etc/fstab."
    cat ${VM_ROOT}/etc/fstab || die "UBE50" "Failed to create /etc/fstab."

    linfo "Configuring /etc/environment"
    sudo chroot ${VM_ROOT} sh -c 'cat > /etc/environment <<EOF
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
LANGUAGE="en_US:en"
LANG="en_US.UTF-8"
EOF' || die "UBE50" "Failed to create /etc/environment."
    cat ${VM_ROOT}/etc/environment || die "UBE50" "Failed to create /etc/environment."

    linfo "Reconfigure locales."
sudo chroot ${VM_ROOT} /bin/bash -c 'locale-gen "en_US.UTF-8"' || die "UBE50"
sudo chroot ${VM_ROOT} /bin/bash -c 'locale-gen "en_GB.UTF-8"' || die "UBE50"
sudo chroot ${VM_ROOT} /bin/bash -c 'dpkg-reconfigure locales' || die "UBE50"

    linfo "Configuring /etc/network/interfaces with static IP: $KVM_IP_STATIC"
    sudo env KVM_IP_STATIC=$KVM_IP_STATIC   \
             KVM_IP_NETMASK=$KVM_IP_NETMASK \
             KVM_IP_GATEWAY=$KVM_IP_GATEWAY \
             chroot ${VM_ROOT} /bin/bash -c 'cat > /etc/network/interfaces <<EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# DHCP eth0
#auto eth0
#iface eth0 inet dhcp

# Static eth0
auto eth0
iface eth0 inet static
      address ${KVM_IP_STATIC}
      netmask ${KVM_IP_NETMASK}
      gateway ${KVM_IP_GATEWAY}
EOF' || die "UBE50"
    cat ${VM_ROOT}/etc/network/interfaces || die "UBE50" "Failed to create /etc/network/interfaces."


    linfo "Creating /etc/resolv.conf"
    sudo env KVM_DOMAIN=$KVM_DOMAIN \
             KVM_SEARCH_DOMAIN="$KVM_SEARCH_DOMAIN" \
             KVM_IP_NAMESERVER=$KVM_IP_NAMESERVER \
             chroot ${VM_ROOT} /bin/bash -c 'cat > /etc/resolv.conf<<EOF
domain ${KVM_DOMAIN}
search ${KVM_SEARCH_DOMAIN}
nameserver ${KVM_IP_NAMESERVER}
EOF' || die "UBE50"
    cat ${VM_ROOT}/etc/resolv.conf || die "UBE50" "Failed to create /etc/resolv.conf."


    linfo "Creating /etc/hostname"
    sudo env KVM_HOSTNAME=$KVM_HOSTNAME \
        chroot ${VM_ROOT} /bin/bash -c 'cat > /etc/hostname<<EOF
${KVM_HOSTNAME}
EOF' || die "UBE50"
    cat ${VM_ROOT}/etc/hostname || die "UBE50" "Failed to create /etc/hostname."

    linfo "Creating /etc/hosts"
    sudo env KVM_HOSTNAME=$KVM_HOSTNAME KVM_FQDN=$KVM_FQDN \
        chroot ${VM_ROOT} /bin/bash -c 'cat > /etc/hosts<<EOF
127.0.0.1 localhost.localdomain localhost
127.0.0.1 ${KVM_FQDN} ${KVM_HOSTNAME}
EOF' || die "UBE50"
    cat ${VM_ROOT}/etc/hosts || die "UBE50" "Failed to create /etc/hosts."


    ${UB_HOME}/11-umount-image.bash || die
)