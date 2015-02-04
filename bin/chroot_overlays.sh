#!/bin/bash

#
# This will copy the overlay files into the correct locations
#

pushd ${OVERLAYS_DIR} &> /dev/null

for DIR in $(ls); do

	sudo cp -r ${DIR} ${BUILD_DIR}/.

done

popd &> /dev/null
