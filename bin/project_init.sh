#!/bin/bash

# Make the source directory if needed
if [ ! -d ${SOURCE_DIR} ]; then
	echo "Making dir '${SOURCE_DIR}'"
        mkdir ${SOURCE_DIR}
fi

# Make the cache directory if needed
if [ ! -d ${CACHE_PACKAGE_DIR} ]; then
	echo "Making dir '${CACHE_PACKAGE_DIR}'"
	mkdir ${CACHE_PACKAGE_DIR}
fi

pushd ${SOURCE_DIR} &>/dev/null

# Get the ISOs we need
if [[ ! -f "${SOURCE_DIR}/${ORIG_ISO}" ]]; then
	wget ${ORIG_ISO_DOWNLOAD}
fi

# rsync the ISO
if [ ! -d ${ORIG_NAME} ]; then
	mkdir tmp &>/dev/null

	# Mount the ISO
	sudo mount -o loop ${ORIG_ISO} tmp &>/dev/null

	# Sync
	echo "Syncing ISO to '${ORIG_NAME}'"
	sudo rsync -aSH tmp/ ${ORIG_NAME} 

	# Unmount the ISO
	sudo umount tmp

	rm -rf tmp

fi

# Remove the old link
rm -f mnt

# Create a new link
ln -s ${ORIG_NAME} mnt 

popd &>/dev/null
