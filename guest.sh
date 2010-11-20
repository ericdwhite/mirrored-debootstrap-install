#!/bin/bash
#
# Exports some environment variables specific to the guest being created.
#
# The idea is to put the ones that vary the most first, eg. hostname
# and IP so that they can be set by a script.  The defaults are in
# `config.bash`.
#
# The following environment variables are exported in addtion to those
# defined in `config.bash`.
#
# KVM_HOSTNAME - Short hostname, e.g. "vm-001".
# KVM_DOMAIN - Fully qualified domainname of the guest, e.g. "example.com".
# KVM_FQDN - generated from the hostname and domainname.
# KVM_SEARCH_DOMAIN - generated from the domainname.
# KVM_IP_STATIC - Initial static IP for the guest.
# KVM_IP_NETMASK - Guest netmask for the static IP interface.
# KVM_IP_GATEWAY - Guest network gateway.
# KVM_IP_NAMESERVER - Name server reachable from the guest.

function usage {
  echo "Usage: $0 --shell -v <HOSTNAME> -d <DOMAINNAME> -s <STATICIP> -m <NETMASK> -g <GATEWAY> -n <NAMESERVER>"
  echo "   Start a /bin/bash shell with a configured environment."
  echo "     $0 --shell -v <HOSTNAME> -d <DOMAINNAME> -s <STATICIP> -m <NETMASK> -g <GATEWAY> -n <NAMESERVER>"
  echo
}

if [ -z $1 ]; then
  usage
  exit -1;
fi

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  usage
  exit 0;
fi

# Provide the option to drop into a configured shell so that commands
# can be run individually.
if [ "$1" == "--shell" ]; then
  UB_SHELL=/bin/bash
  shift
fi

while getopts "v:d:s:m:g:n:" opt
do
  case "$opt" in
        v) KVM_HOSTNAME=$OPTARG;;
        d) KVM_DOMAIN=$OPTARG;;
        s) KVM_IP_STATIC=$OPTARG;;
        m) KVM_IP_NETMASK=$OPTARG;;
        g) KVM_IP_GATEWAY=$OPTARG;;
        n) KVM_IP_NAMESERVER=$OPTARG;;
  esac
done

# Initialize some helpers
UB_HOME=`dirname $(readlink -f $0)`
export UB_HOME
. ${UB_HOME}/functions.bash

# Load the base configuration
linfo "Loading configuration from ${UB_HOME}/config.bash"
. ${UB_HOME}/config.bash || die

if [ -z $KVM_HOSTNAME ]; then
    KVM_HOSTNAME=$DEFAULT_KVM_HOSTNAME
fi
export KVM_HOSTNAME

if [ -z $KVM_IP_STATIC ]; then
    KVM_IP_STATIC=$DEFAULT_KVM_IP_STATIC
fi
export KVM_IP_STATIC

if [ -z $KVM_DOMAIN ]; then
    KVM_DOMAIN=$DEFAULT_KVM_DOMAIN
fi
export KVM_DOMAIN

if [ -z $KVM_IP_NETMASK ]; then
    KVM_IP_NETMASK=$DEFAULT_KVM_IP_NETMASK
fi
export KVM_IP_NETMASK

if [ -z $KVM_IP_GATEWAY ]; then
    KVM_IP_GATEWAY=$DEFAULT_KVM_IP_GATEWAY
fi
export KVM_IP_GATEWAY

if [ -z $KVM_IP_NAMESERVER ]; then
    KVM_IP_NAMESERVER=$DEFAULT_KVM_IP_NAMESERVER
fi
export KVM_IP_NAMESERVER

KVM_FQDN=${KVM_HOSTNAME}.${KVM_DOMAIN}
export KVM_FQDN

KVM_SEARCH_DOMAIN="${KVM_DOMAIN}"
export KVM_SEARCH_DOMAIN

export DISK_IMAGE=${KVM_HOSTNAME}_ubuntu-${U_RELEASE}-${U_ARCH}.img
export VM_ROOT=${U_RELEASE}-${U_ARCH}-vm

echo "Using network configuration"
echo "  hostname  : $KVM_HOSTNAME"
echo "  domain    : $KVM_DOMAIN"
echo "  fqdn      : $KVM_FQDN"
echo "  static-ip : $KVM_IP_STATIC"
echo "  netmask   : $KVM_IP_NETMASK"
echo "  gateway   : $KVM_IP_GATEWAY"
echo "  nameserver: $KVM_IP_NAMESERVER"
echo "  diskimage : $DISK_IMAGE"

if [ $UB_SHELL ]; then
    $UB_SHELL
fi
