#!/bin/bash

#
# This will install and update packages in the chroot envrioment
#

# APT Update 
chrootCommand ${CHROOT_DIR} "apt-get update && apt-get -y upgrade" 

# Install packages from plan directory
for FILE in $(ls ${PLANS_DIR}); do

        OLD_IFS=$IFS
        IFS=$'\n'

	for PACKAGE in $(cat ${PLANS_DIR}/${FILE} | grep -v '^$\|^\s*\#'); do
		if [[ -f ${IMPORT_DIR}/${PACKAGE} ]]; then 
			echo "INSTALLING LOCAL ${PACKAGE}"

			chrootCommand ${CHROOT_DIR} "dpkg -i /import/${PACKAGE}"
			chrootCommand ${CHROOT_DIR} "apt-get install -f"

		elif [[ -f "${IMPORT_DIR}/${PACKAGE}.deb" ]]; then
			echo "INSTALLING LOCAL DEB ${PACKAGE}"

			chrootCommand ${CHROOT_DIR} "dpkg -i /import/${PACKAGE}.deb"
			chrootCommand ${CHROOT_DIR} "apt-get install -f"
		else
			
			echo "APT INSTALL ${PACKAGE}"
			
			chrootCommand ${CHROOT_DIR} "apt-get install -y ${PACKAGE}"
		fi
	done

        IFS=${OLD_IFS}
done

