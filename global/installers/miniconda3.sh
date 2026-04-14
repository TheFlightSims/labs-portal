#!/bin/bash

################################
# Error handing
set -euo pipefail
trap 'echo "Error occurred at line ${LINENO} of ${BASH_SOURCE[0]}."; exit 1' ERR
################################

################################
# Global configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCH=$(uname -m)
export PATH="/usr/local/bin:$PATH"
################################

################################
# Running some checks
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi
################################

################################
# Prepare conda package manager

## Download the installer
echo "Installing Miniconda3"
curl -SL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$ARCH.sh \
    -o /tmp/miniconda.sh
if [ $? -ne 0 ]; then
    echo "Error downloading Miniconda3 installer."
    exit 1
fi

## Preform installing
chmod +x /tmp/miniconda.sh
bash /tmp/miniconda.sh -bfp /usr/local
if [ $? -ne 0 ]; then
    echo "Error installing Miniconda3."
    exit 1
fi
rm -rf /tmp/miniconda.sh

## Prepare conda environment
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
conda config --add channels conda-forge
conda config --set channel_priority strict

## Install Python 3
conda install -y python=3
if [ $? -ne 0 ]; then
    echo "Error installing Python 3 via Conda."
    exit 1
fi

## Install PyPI server package
echo -e "Installing base packages"
pip install -r "$SCRIPT_DIR/../packages/pip_server.txt" \
    --default-timeout=3600
if [ $? -ne 0 ]; then
    echo "Error while installing server packages. Retrying..."
    exit 1
fi

## Install PyPI client package
echo -e "Installing client packages"
pip install -r "$SCRIPT_DIR/../packages/pip_client.txt" \
    --default-timeout=3600
if [ $? -ne 0 ]; then
    echo "Error while installing server packages. Retrying...";
    exit 1
fi

## Upgrade all PyPI packages
conda update --all -y
if [ $? -ne 0 ]; then
    echo "Error updating Conda packages."
    exit 1
fi
################################

echo "Install Miniconda 3 completed"
