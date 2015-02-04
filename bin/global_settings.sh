#!/bin/bash

#
# These variables are the global settings, and will set any defaults they may not have been set in setting files 
#

# We need to have a GPG key
if [[ -z {$GPG_KEY} ]]; then
	echo "A GPG key must be specified"
	exit 2
fi

# We will build an ubuntu image by default
${IMAGE_NAME:='ubuntu-custom'}
${IMAGE_VERSION:='1'}
${ORIG_ISO:='ubuntu-14.04.1-server-amd64.iso'}
${ORIG_ISO_DOWNLOAD:="http://releases.ubuntu.com/14.04.1/${ORIG_ISO}"}
${PACKAGE_URL:='http://archive.ubuntu.com/ubuntu'}

# Drop the iso to get the name
ORIG_NAME=$(echo "${ORIG_ISO}" | awk -F'.iso' '{print $1}') 

# Where we build the new ISO
BUILD_DIR="${PROJECT_DIR}/build" 

# The filesystem of the new ISO
CHROOT_DIR="${BUILD_DIR}/chroot" 

# The contents of the new ISO
ISO_DIR="${BUILD_DIR}/iso" 

# The original ISO locations
SOURCE_DIR="${BASE_DIR}/src" 

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

