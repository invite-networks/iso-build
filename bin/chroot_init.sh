#!/bin/bash

#
# This is the setup for the chroot enviroment
#

echo "Setting up chroot enviroment"
pushd {$BUILD_DIR} &> /dev/null 

# DNS Support
echo 'nameserver 4.2.2.2' | sudo tee ${CHROOT_DIR}/etc/resolv.conf

# Copy local packages into the chroot
sudo gpg --export -a ${GPG_KEY} > ${IMPORT_DIR}/gpg.key
checkReturn $? "GPG export for key ${GPG_KEY}"
sudo cp -r ${IMPORT_DIR} ${CHROOT_DIR}/.

# Mounts
sudo mount --bind /dev/ ${CHROOT_DIR}/dev
chrootCommand ${CHROOT_DIR} "mount -t proc none /proc"
chrootCommand ${CHROOT_DIR} "mount -t sysfs none /sys"
chrootCommand ${CHROOT_DIR} "mount -t devpts none /dev/pts"

# Variables
chrootCommand ${CHROOT_DIR} "export HOME=/root"
chrootCommand ${CHROOT_DIR} "export LC_ALL=C"
chrootCommand ${CHROOT_DIR} "dpkg-divert --local --rename --add /sbin/initctl"
chrootCommand ${CHROOT_DIR} "ln -s /bin/true /sbin/initctl"

# Stop services from restarting on update or install
chrootCommand ${CHROOT_DIR} "echo '#!/bin/bash' > /usr/sbin/policy-rc.d" 
chrootCommand ${CHROOT_DIR} "echo 'exit 101' >> /usr/sbin/policy-rc.d"
chrootCommand ${CHROOT_DIR} "chmod +x /usr/sbin/policy-rc.d"

# Locale
echo 'en' > ${ISO_DIR}/isolinux/lang 
chrootCommand ${CHROOT_DIR} "locale-gen en_US en_US.UTF-8"

# Install the INVITE key
chrootCommand ${CHROOT_DIR} "cat /import/local_key.gpg | apt-key add -"

popd &> /dev/null

