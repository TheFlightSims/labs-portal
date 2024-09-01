#!/bin/bash
if [ "$EUID" -ne 0 ]
	then echo -e "Please run the script as root, or using sudo\n"
	exit
fi

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
	DISTRO=ubuntu-22.04
else
	echo -e "\nUser cancelled. Exiting..."
	exit
fi

echo -e -n "\n"
CONFIRM_FULL_INSTALL="n"
echo -n "Do you want a full installation? [y/N]: "
read -n 1 CONFIRM_FULL_INSTALL

chmod +x ./$DISTRO/*.sh

./$DISTRO/reset_cache_to_install_node.sh
./$DISTRO/update_apt_repo.sh
if [ $? -eq 0 ]; then
	echo "[LABS PORTAL APT CP] APT Processes is finished."
else
	echo "[LABS PORTAL APT CP] APT Processes is failed. Failing the installer..."
	exit
fi

./$DISTRO/install_pip_npm.sh
if [ $? -eq 0 ]; then
	echo "[LABS PORTAL PIP+NPM CP] PIP+NPM Processes is finished."
else
	echo "[LABS PORTAL PIP+NPM CP] PIP+NPM Processes is failed. Failing the installer..."
	exit
fi

./$DISTRO/copy-configs.sh
echo -e "Copying default SQLite"
cp ./$DISTRO/res/jupyterhub.sqlite /etc/jupyter/
echo -e "Copying standard configurations"
cp ./$DISTRO/res/config.py /etc/jupyter/config.py
chmod 700 /etc/jupyter
if [ $? -eq 0 ]; then
	echo "[LABS PORTAL CF CP] Configuration copying is finished."
else
	echo "[LABS PORTAL CF CP] Configuration copying is failed. Failing the installer..."
	exit
fi

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
