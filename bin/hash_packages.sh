#!/bin/bash
#
# This script will hash the packages and the repo and sign it
#

if [[ ! -d ${REPO_DIR} ]]; then
	mkdir ${REPO_DIR}
fi

tee ${REPO_DIR}/apt-udeb.conf <<EOF 
Dir {
	ArchiveDir ".";
};

Default {
	Packages::Compress ". gzip";
   	Packages {
		Extensions ".udeb";
  	};
};

BinDirectory "pool/main" {
    Packages "dists/stable/main/debian-installer/binary-amd64/Packages";
};

TreeDefault {
	Directory "pool/";
};
EOF

tee ${REPO_DIR}/apt-deb.conf <<EOF
Dir {
	ArchiveDir ".";
};

Default {
	Packages::Compress ". gzip";
   	Packages {
		Extensions ".deb";
  	};
};

BinDirectory "pool/main" {
    Packages "dists/stable/main/binary-amd64/Packages";
};

TreeDefault {
	Directory "pool/";
};
EOF

tee ${REPO_DIR}/apt-release.conf <<EOF
APT::FTPArchive::Release::Origin "${AUTHOR}";
APT::FTPArchive::Release::Label "${AUTHOR}";
APT::FTPArchive::Release::Components "main contrib";
APT::FTPArchive::Release::Architectures "amd64";
APT::FTPArchive::Release::Suite "stable";
APT::FTPArchive::Release::Codename "${BUILD_NAME}";
EOF

pushd ${ISO_DIR} &>/dev/null

        sudo apt-ftparchive generate ${REPO_DIR}/apt-udeb.conf
        sudo apt-ftparchive generate ${REPO_DIR}/apt-deb.conf
        sudo apt-ftparchive -c ${REPO_DIR}/apt-release.conf release dists/stable | sudo tee dists/stable/Release

        if [[ -z ${GPG_PASSWORD} ]]; then
                sudo gpg --yes -u ${GPG_KEY} --sign -bao dists/stable/Release.gpg dists/stable/Release
        else
                sudo gpg --yes -u ${GPG_KEY} --passphrase "${GPG_PASSWORD}" --sign -bao dists/stable/Release.gpg dists/stable/Release
        fi

        checkReturn $? "GPG signing"

popd &>/dev/null
