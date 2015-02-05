#!/bin/bash

# Checks the return status
function checkReturn {
        if [ $1 -ne 0 ]; then
                echo "FAIL: $2"

		exit_clean $1

        else
                echo "PASS: $2"
        fi
}

# This will be called to exit
function exit_clean {
	echo "Exiting cleanly from script"
	
	IGNORE_ERRORS=1
	source bin/chroot_clean.sh

	exit $1
}

# Cleans up the build
function clean {
	echo "Reinitilizing the build directory"
	sudo rm -rf ${BUILD_DIR} && mkdir ${BUILD_DIR} 
}

# Start the build from scratch
function clean_all {
	echo "Reinitilizing the cache directory"
        sudo rm -rf ${CACHE_PACKAGE_DIR} && mkdir ${CACHE_PACKAGE_DIR}	
}	

# Runs a command inside a chroot enviroment
function chrootCommand {
        sudo chroot $1 /bin/bash -c "$2"
	RETVAL=$?

	# If the IGNORE_ERROS flag is not marked check for an error
	if [[ -z ${IGNORE_ERRORS} ]]; then
		checkReturn ${RETVAL} "chroot command '$2'"
	fi
}

# This will copy or download additional packages that need to included in the ISO
function copyOrDownload {
        FILE=$1
        INSTALL=$(echo -n "${FILE}" | awk -F'/' '{print $NF}')
        INSTALL_PATH=$(dirname $FILE)

        if [[ -f ${ISO_DIR}/${FILE} ]]; then
                echo "EXISTS: ${ISO_DIR}/${FILE}" 

        elif [[ -f "${FILE}" ]]; then
                sudo cp --parents ${FILE} "${ISO_DIR}/."
                RETVAL=$?
                checkReturn ${RETVAL} "PUSHD COPY - ${FILE}"

        elif [[ -f "${CACHE_PACKAGE_DIR}/${FILE}" ]]; then
                pushd ${CACHE_PACKAGE_DIR} &> /dev/null
                sudo cp --parents ${FILE} "${ISO_DIR}/."
                RETVAL=$?
                popd &> /dev/null

                checkReturn ${RETVAL} "CACHE COPY - ${FILE}"

        else
                wget -P "${CACHE_PACKAGE_DIR}/${INSTALL_PATH}/" ${PACKAGE_URL}/${INSTALL_PATH}/${INSTALL}
                RETVAL=$?
                checkReturn ${RETVAL} "DOWNLOAD - ${FILE}"

                pushd ${CACHE_PACKAGE_DIR} &> /dev/null
                sudo cp --parents ${FILE} "${ISO_DIR}/."
                RETVAL=$?
                popd &> /dev/null

                checkReturn ${RETVAL} "DOWNLOAD COPY - ${FILE}"

		NAME=$(echo -n "${INSTALL}" | awk -F'_' '{print $1}')

		for FILE in $(ls ${ISO_DIR}/${INSTALL_PATH}/${NAME}_* 2>/dev/null); do
			if [ $FILE =! ${INSTALL} ]; then
				rm -f ${ISO_DIR}/${INSTALL_PATH}/${FILE}
				rm -f ${CACHE_PACKAGE_DIR}/${INSTALL_PATH}/${FILE}
				echo ""
                        	echo ""
                        	echo "DELETE ${DELETE}"
                        	echo ""
                        	echo ""
			fi
		done

        fi
}

