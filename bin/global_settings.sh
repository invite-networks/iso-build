#!/bin/bash

#
# This is the varibles that will be imported into each script
#

if [[ -z ${BUILD_TYPE} || -z ${PROJECT_DIR} ]]; then
	echo "The BUILD_TYPE, and PROJECT_DIR variables must be set to continue"
	exit 2
fi

if [ ${BUILD_TYPE} == 'ubuntu' ]; then
	ORIG_ISO='ubuntu-14.04.1-server-amd64.iso'
	ORIG_ISO_LOCATION="http://releases.ubuntu.com/14.04.1/${ORIG_ISO}"
	PACKAGE_URL='http://archive.ubuntu.com/ubuntu'

elif [ ${BUILD_TYPE} == 'debian' ]; then
	echo "ADD TO THIS"
	exit 2

else
	echo "Unsupported type '${BUILD_TYPE}'"
	exit 2

fi

# Where we build the new ISO
BUILD_DIR="${PROJECT_DIR}/build" 

# The filesystem of the new ISO
CHROOT_DIR="${BUILD_DIR}/chroot" 

# The contents of the new ISO
ISO_DIR="${BUILD_DIR}/iso" 

# The original ISO locations
SOURCE_DIR="${BASE_DIR}/src" 

# Drop the iso to get the name
ORIG_NAME=$(echo "${ORIG_ISO}" | awk -F'.iso' '{print $1}') 

# Temporary directory put on the filesystem, this is used for local packages to be installed or to copy files etc 
IMPORT_DIR="${PROJECT_DIR}/import"

# Cached downloaded packages
CACHE_PACKAGE_DIR="${PROJECT_DIR}/.cache"

# Plan directory that includes packages to install
PLANS_DIR="${PROJECT_DIR}/plans"

# Overlay directory
OVERLAYS_DIR="${PROJECT_DIR}/overlays"

# Commands directory
COMMANDS_DIR="${PROJECT_DIR}/commands"

# Information to build a repo
REPO_DIR="${BASE_DIR}/repo"

