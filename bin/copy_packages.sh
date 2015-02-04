#!/bin/bash

# Get the list of installed packages on the filesystem 
if [[ ! -z ${COPY_PACKAGES} ]]; then
        for PACKAGE in $(sudo chroot ${CHROOT_DIR} dpkg-query -W --showformat='${Package}\n'); do

                # Filenames from apt-cache may be multiple
                FILES=$(sudo chroot ${CHROOT_DIR} apt-cache show ${PACKAGE} | grep Filename | cut -d ' ' -f2)

                # If we don't have a filename check locally for the install
                if [[ -z "$FILES" ]]; then
                        FILE=$(ls ${IMPORT_DIR}/${PACKAGE}_*.deb 2>/dev/null)
                        RETVAL=$?

                        checkReturn ${RETVAL} "LOCAL FILE SEARCH - ${PACKAGE}"

                        copyOrDownload ${FILE}

                else
                        for FILE in $FILES; do

                                copyOrDownload ${FILE}

                        done
                fi
        done
fi
