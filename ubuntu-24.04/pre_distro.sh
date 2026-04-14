#!/bin/bash

################################
# Error handing
set -euo pipefail
trap 'echo "Error occurred at line ${LINENO} of ${BASH_SOURCE[0]}. "; exit 1' ERR
################################

################################
# Global configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
################################

################################
# Running some checks
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi
################################

################################
# Prepare local package manager

cd "$SCRIPT_DIR"

# APT
echo -e "Updating local apt-get Repos"

apt-get update
if [ $? -ne 0 ]; then
	echo "Failed to fetch the apt-get repos."
	exit 1
fi

apt-get full-upgrade -y
if [ $? -ne 0 ]; then
	echo "Failed to upgrade the apt-get packages."
	exit 1
fi

apt-get install -y openssl pwgen git nodejs npm \
    yarn gcc g++ make zip libtool tar gzip
if [ $? -ne 0 ]; then
	echo "apt-get failed to install packages."
	exit 1
fi
################################

echo "Prepare for distro has been completed!"
