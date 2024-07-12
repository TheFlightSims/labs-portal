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

CONFIRM="n"
echo -n "Do you wish to start the installer [Y/N]?: "
read -n 1 CONFIRM_INPUT
if [[ "${CONFIRM_INPUT}" =~ ^[Yy]$ ]]; then
	cat ./welcome.txt
else
	echo -e "Exiting the installer..."
	exit
fi

chmod +x ./.global/*.sh && chmod +x ./linux/*.sh
./.global/update_apt_repo.sh
if [ $? -eq 0 ]; then
	echo "[LABS PORTAL APT CP] APT Processes is finished."
else
	echo "[LABS PORTAL APT CP] APT Processes is failed. Failing the installer..."
	exit
fi

./.global/install_pip_npm.sh
if [ $? -eq 0 ]; then
	echo "[LABS PORTAL PIP+NPM CP] PIP+NPM Processes is finished."
else
	echo "[LABS PORTAL PIP+NPM CP] PIP+NPM Processes is failed. Failing the installer..."
	exit
fi

./.global/copy-configs.sh
if [ $? -eq 0 ]; then
	echo "[LABS PORTAL CF CP] Configuration copying is finished."
else
	echo "[LABS PORTAL CF CP] Configuration copying is failed. Failing the installer..."
	exit
fi

./linux/linux_install.sh
if [ $? -eq 0 ]; then
	echo "[LABS PORTAL LX CP] Linux customization copying is finished."
else
	echo "[LABS PORTAL LX CP] Linux customization copying is failed. Failing the installer..."
	exit
fi

echo -e -n "[LABS PORTAL Docker Installation] The installation is finished!"
