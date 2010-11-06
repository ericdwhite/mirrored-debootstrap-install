#!/bin/bash
#
# Determines the list of packages to create a baseline Ubuntu install
# and mirrors those packages locally.
#
# The Ubuntu release and architecture are set in:
#   config.sh
#
# Note: This script can be used after the fact to update the mirror
# with additional packages.  This is useful the mirror has already
# been created and you discover a few more packages are required for
# the minimal guest vm.
#
if [ -z $UB_CONFIGURED ]; then
  echo "Please execute 'guest.bash' to configure the environment first."
  exit 1
fi

# Initialise some helpers
. ${UB_HOME}/functions.bash

mkdir -p ${U_RELEASE}-${U_ARCH}-bootstrap/tmp

#
# Find the list of baseline packages.
#
(cd ${U_RELEASE}-${U_ARCH}-bootstrap
    if [ -r debootstrap.packages ]; then
	linfo "Using existing debootstrap.packages"
    else
	linfo "Creating debootstrap.packages"
	debootstrap --print-debs --arch=${U_ARCH} ${U_RELEASE} `pwd`/tmp > debootstrap.packages
	if [ $? -ne 0 ]; then
	    lerror "debootstrap exited with: $?"
	    rm -f debootstrap.packages
	    die "UBE001"
	fi

	linfo "Found the following packages"
	cat debootstrap.packages
    fi
)

#
# Create the mirror
#
mkdir -p ${U_RELEASE}-${U_ARCH}-bootstrap/mirror
(cd ${U_RELEASE}-${U_ARCH}-bootstrap/mirror
    mkdir -p conf
    cat > conf/distributions <<EOF
Codename: ${U_RELEASE}
Architectures: ${U_ARCH} source
Description: Ubuntu ${U_RELEASE}-${U_ARCH} (Required packages only)
Components: main
Update: ubuntu-${U_RELEASE}-${U_ARCH}-update

Codename: ${U_RELEASE}-updates
Architectures: ${U_ARCH} source
Description: Ubuntu ${U_RELEASE}-${U_ARCH} Updates (Required packages only)
Components: main
Update: ubuntu-${U_RELEASE}-${U_ARCH}-update
EOF

    cat > conf/updates <<EOF
Name: ubuntu-${U_RELEASE}-${U_ARCH}-update
Method: ${U_MIRROR}
Components: main
Architectures: ${U_ARCH} source
FilterList: purge all-packages.mirror
VerifyRelease: blindtrust
EOF

    # Create a mirror request file based on the orignal package list
    for pkg in $(cat ../debootstrap.packages); do
        echo $pkg install;
    done > conf/debootstrap.mirror || die "UBE002"
    linfo "The following packages to be mirrored are listed in:" `pwd`/conf/debootstrap.mirror
    linfo "  partial listing:"
    cat conf/debootstrap.mirror | sort | head -3
    echo  "..."
    cat conf/debootstrap.mirror | sort | tail -2

    # Add the list of additional packages from the ${UB_HOME}/additional.packages
    #  Note: we copy it and filter out comments and empty lines.
    if [ -r ${UB_HOME}/additional.packages ]; then
	linfo "Finding dependencies for packages listed in: ${UB_HOME}/additional.packages"
	cat ${UB_HOME}/additional.packages | grep -Ev '^#.*|^\s*$' | sort > additional.packages
	cat additional.packages
    else
	lerror "Please specify at least a kernel in: ${UB_HOME}/additional.packages"
	die "UBE003"
    fi
    
    # Use configure and use germinate to find out the dependencies for those additional packages.
    mkdir -p seeds
    touch seeds/blacklist
    touch seeds/supported
    cat > seeds/STRUCTURE <<EOF
required:
supported:
EOF
    linfo "Seeding with: " `pwd`/seeds/required
    for pkg in $(cat additional.packages); do
	echo " * $pkg";
    done > seeds/required

    linfo "Germinating... this code take a while"
    mkdir -p germinate
    (cd germinate && \
	germinate -v -m ${U_MIRROR} \
            -a ${U_ARCH} \
            -d ${U_RELEASE} \
            -c main \
            -s seeds \
            -S file://`pwd`/.. || die "UBE004"
    )

    linfo "Defining the complete list of packages in: " `pwd`/conf/all-packages.mirror
    cat conf/debootstrap.mirror > germinate/all-packages.mirror
    for pkg in $(cat germinate/required \
	| tail -n +3 \
	| head -n -2 \
	| cut -d '|' -f 1); do
	echo $pkg install;
    done >> germinate/all-packages.mirror
    cat germinate/all-packages.mirror | sort -u > conf/all-packages.mirror
    cat conf/all-packages.mirror | head -3
    echo " ..."
    cat conf/all-packages.mirror | tail -2

    #
    # Now finally populate the mirror
    linfo "Populating the mirror.  This could take some time..."
    reprepro --noskipold -V update ${U_RELEASE} || die "UBE005"
    reprepro --noskipold -V update ${U_RELEASE}-updates || die "UBE006"

    linfo "Successfully populated the mirror!"
)
