Creating a KVM Ubuntu VM using Debootstrap
------------------------------------------

This repository contains scripts to automatically create a KVM image
based on the parameters specified in `config.sh`.

The overall process is described [here](http://TODO)

Requirements:
 * Debian/Ubuntu starting system
 * sudo

Working with Partial Installs
-----------------------------

The scripts are intended to be run one after another, but during
testing it is sometime handly to rerun bits of the process to fine
tune the result.

Updating the Additional Packages List
=====================================
If you find that part way through the installation process you would
like additional packages.  You can modify `additional.packages` and
re-run `01-create-boostrap-mirror.bash` the new packages will be
downloaded and mirror updated.  This process should only take a small
amount of time as only the new packages will be downloaded.

Re-running the script will also download new updates for previously
mirrored packages.

Utilities
=========
The following utility scripts are useful for dealing with the choot VM.

 * `10-mount-image.bash` -- Mounts the VM in the host
 * `11-umount-image.bash` -- Unmounts the VM in the host
 * `12-chroot.bash` -- Chroot into a mounted VM (Can be run standalone)

