#!/bin/bash

################################
# Error handing
set -euo pipefail
trap 'echo "Error occurred at line ${LINENO} of ${BASH_SOURCE[0]}. Exiting..."; exit 1' ERR
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

if [[ "$SCRIPT_DIR" == *" "* ]]; then
	echo "The directory name '$SCRIPT_DIR' contains spaces. Exiting..."
	exit 1
fi

if  [ ! -f "$SCRIPT_DIR/global/tutorials-notebooks/_is_cloning_properly" ] || \
	[ ! -f "$SCRIPT_DIR/global/web-portal/_is_cloning_properly" ]; then
		echo "Failed to check the current git status. Failing the installer"
		exit 1
fi
################################

################################
# Prepare environment and context changes
cd "$SCRIPT_DIR"
for bf in $(find "$SCRIPT_DIR" | grep -E ".*\.sh$"); do
	echo "Change mode with +r for file: $bf"
	chmod +x "$bf"
done
################################

################################
# Welcome screen
DISTRO_SEL="0"
cat << EOF
The installer is running within the path: $SCRIPT_DIR

========================================================
|               WARNING - BEFORE INSTALL               |
========================================================

IT IS RECOMMENDED THAT LABS PORTAL CAN ONLY BE INSTALLED
ON NEW SERVER, OR A DOCKER CONTAINER. DO NOT INSTALL IT 
ONTO A FUNCTIONAL SERVER THAT RUNNING OTHER SERVICE - IT 
MAY BREAK YOUR SYSTEM!

YOU HAVE BEEN WARNED!
-------------------------------------------------------

The installer has started successfully.
DO NOT make any modifications to the system from now on.

Keep your system running, and make sure your Internet is 
connected and running  properly.

The project is linked with MIT license.
--------------------------------
For current instance, there are some available configurations 
for different Linux distributions:

[1]: Ubuntu 24.04 LTS
[Anything else]: Exit
EOF
echo -n "Choose your offer: "
read -n 1 DISTRO_SEL
if [[ "${DISTRO_SEL}" =~ ^[1]$ ]]; then
	DISTRO=ubuntu-24.04
else
	echo -e "\nInvalid selection. Exiting...\n"
	exit 1
fi
################################

################################
# Preform installing
bash "$SCRIPT_DIR/$DISTRO/pre_distro.sh"
if [ $? -ne 0 ]; then
	echo "Pre-installation for the distro has failed."
	exit 1
fi

bash "$SCRIPT_DIR/global/miniconda3.sh"
if [ $? -ne 0 ]; then
	echo "Miniconda 3 installation has failed."
	exit 1
fi

bash "$SCRIPT_DIR/$DISTRO/post_distro.sh"
if [ $? -ne 0 ]; then
	echo "Post-installation for the distro has failed."
	exit 1
fi
################################

echo "The installation is finished!"
