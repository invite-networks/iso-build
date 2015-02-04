#!/bin/bash

# Catch ctrl_c 
trap exit_clean INT 

# Check for root permissions
if [ $(whoami) != 'root' ]; then
	echo "You must run this script as root!"
	exit 2
fi

# Get the script directory
BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [[ -z $1 ]]; then
	echo "You must specifiy a project to build!"
	echo "ex ./build.sh projects/myproject"
	exit 2;

else
	# Set the project directory based on the input

	if [[ $1 =~ projects/ ]]; then
		PROJECT=$(echo $1 | sed 's/\/$//g')
		PROJECT_DIR="${BASE_DIR}/${PROJECT}"
	else
		PROJECT_DIR="${BASE_DIR}/projects/$1"
	fi

	# Check that the project directory exists
	if [[ ! -d "${PROJECT_DIR}" ]]; then
		echo "The project was not found in ${PROJECT_DIR}" 
		exit 2;
	fi
fi

# Check that the projects directory is with the build script 
# We do this to be sure the script hasn't been moved so we don't cause any problems
if [[ ! -d "${BASE_DIR}/projects" ]]; then
	echo "We did not find a project directory with the build script!"
	echo "Either create the projects directory, or move the script back to the original location"
	
	exit 2	
fi

# Run the supporting scripts
source ${BASE_DIR}/settings 
source ${PROJECT_DIR}/settings
source ${BASE_DIR}/bin/global_settings.sh 
source ${BASE_DIR}/bin/functions.sh
source ${BASE_DIR}/bin/project_init.sh

# Clean the build
if [[ ${2} == 'clean' ]]; then 
	# Start from scratch
	if [[ ${3} == 'all' ]]; then 
		clean_all
		exit
	fi

	clean
	exit
fi

# Sync the ISO contents to the build directory if needd 
if [[ ! -d ${ISO_DIR} ]]; then
	echo "Syncing the src iso to '${ISO_DIR}'"
	sudo rsync -aSH --exclude=/install/filesystem.squashfs --exclude=/doc ${SOURCE_DIR}/mnt/ ${ISO_DIR} 
fi

if [[ ! -d ${CHROOT_DIR} ]]; then
	echo "Extracting the filesystem to ${CHROOT_DIR}"
	sudo unsquashfs ${SOURCE_DIR}/mnt/install/filesystem.squashfs && sudo mv squashfs-root ${CHROOT_DIR} 
fi

# Setup the chroot enviroment
source bin/chroot_init.sh

# Overlays
source bin/chroot_overlays.sh

# Packages 
source bin/chroot_plans.sh

# Commands
source bin/chroot_commands.sh

# Clean the chroot enviroment
source bin/chroot_clean.sh

# Get the list of installed packages on the filesystem 
source bin/copy_packages.sh

# Generate Packages Hash
source bin/hash_packages.sh

# Build ISO
pushd ${BUILD_DIR} &>/dev/null

	sudo chmod +w ${ISO_DIR}/install/filesystem.manifest
	sudo chroot 'chroot' dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee ${ISO_DIR}/install/filesystem.manifest
	sudo rm -f ${ISO_DIR}/install/filesystem.squashfs
	sudo mksquashfs 'chroot' ${ISO_DIR}/install/filesystem.squashfs -b 1048576
	printf $(sudo du -sx --block-size=1 'chroot' | cut -f1) | sudo tee ${ISO_DIR}/install/filesystem.size && echo ""
	cd ${ISO_DIR} && sudo rm -f md5sum.txt
	find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt
	sudo genisoimage -D -r -V "${IMAGE_NAME}_${IMAGE_VERSION}" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../../${IMAGE_NAME}_${IMAGE_VERSION}.iso .

popd &>/dev/null

