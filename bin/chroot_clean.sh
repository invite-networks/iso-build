#!/bin/bash

#
# This is the clean up the chroot enviroment 
#

echo "Cleaning up chroot enviroment"
pushd {$BUILD_DIR} &> /dev/null 

chrootCommand ${CHROOT_DIR} "rm -rf /packages"
chrootCommand ${CHROOT_DIR} "rm -f /usr/sbin/policy-rc.d"
chrootCommand ${CHROOT_DIR} "cat /dev/null > /etc/resolv.conf"
chrootCommand ${CHROOT_DIR} "apt-get -y autoremove"
chrootCommand ${CHROOT_DIR} "apt-get -y autoclean"
chrootCommand ${CHROOT_DIR} "rm /sbin/initctl"
chrootCommand ${CHROOT_DIR} "dpkg-divert --rename --remove /sbin/initctl"
chrootCommand ${CHROOT_DIR} "umount /proc"
chrootCommand ${CHROOT_DIR} "umount /sys"
chrootCommand ${CHROOT_DIR} "umount /dev/pts"
chrootCommand ${CHROOT_DIR} "rm -rf /tmp/* ~/.bash_history"
sudo umount ${CHROOT_DIR}/dev

popd &> /dev/null

