#!/bin/bash

#
# This will install and update packages in the chroot envrioment
#


# Run the commands in order 
for FILE in $(ls ${COMMANDS_DIR}); do

	OLD_IFS=$IFS
	IFS=$'\n'

	for COMMAND in $(cat ${COMMANDS_DIR}/${FILE} | grep -v '^$\|^\s*\#'); do
		chrootCommand ${CHROOT_DIR} "${COMMAND}"

	done
	
	IFS=${OLD_IFS}
done

