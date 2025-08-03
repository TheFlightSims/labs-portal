#!/bin/bash

set -euo pipefail

CURR_DIR="$(cd "$(dirname "$0")" && pwd)"

trap 'echo "Error occurred at line ${LINENO} of ${BASH_SOURCE[0]}. Exiting..."; exit 1' ERR

(( EUID == 0 )) || { echo "Please run as root"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
echo -e "Starting the installer...\n"
echo -e -n "The installer is running within the path: $PWD\n\n" 

if [ -f ./.global/ext-pkg/_is_cloning_properly ] && \
	[ -f ./.global/tutorials-notebooks/_is_cloning_properly ] && \
	[ -f ./.global/tutorials-notebooks/jupyter-cpp-kernel-doc/_is_cloning_properly ] && \
	[ -f ./.global/web-portal/_is_cloning_properly ]; then
	echo "..."
else
	echo "Failed to check the current git status. Failing the installer"
	exit
fi

DISTRO_SEL="0"
cat ./welcome.txt
echo -n "Choose your offer: "
read -n 1 DISTRO_SEL
if [[ "${DISTRO_SEL}" =~ ^[1]$ ]]; then
	DISTRO=ubuntu-24.04
else
	echo -e "\nInvalid selection. Exiting..."
	exit
fi

echo -e -n "\n"
CONFIRM_FULL_INSTALL="n"
echo -n "Do you want a full installation (Default is No)? [y/N]: "
read -n 1 CONFIRM_FULL_INSTALL

echo -e "\n"

chmod +x ./$DISTRO/*.sh

./$DISTRO/install_standard.sh

if [[ "${CONFIRM_FULL_INSTALL}" =~ ^[Yy]$ ]]; then
	echo -e -n "User selected full installation.\n\n"
	./$DISTRO/install_extended.sh
	if [ $? -eq 0 ]; then
		echo "[LABS PORTAL EXT] Extended installation is finished."
	else
		echo "[LABS PORTAL EXT] Extended installation is failed. Failing the installer..."
		exit
	fi
else
	echo -e -n "User selected minimal installation. \nTherefore, extended Jupyter kernels, NVIDIA CUDA, and AI frameworks will not be installed.\n\n"
fi

echo -e "Cleaning up caches..."
apt autoremove -y
apt autoclean
apt clean
pip cache purge

echo "[LABS PORTAL Installation] The installation is finished!"
