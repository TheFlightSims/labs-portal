#!/bin/bash

################################
# Error handing
set -euo pipefail
trap 'echo "Error occurred at line ${LINENO} of ${BASH_SOURCE[0]}. "; exit 1' ERR
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
# NPM
echo -e "Installing configurable-http-proxy"
npm i -g configurable-http-proxy --unsafe-perm
if [ $? -ne 0 ]; then
    echo "Error while installing configurable-http-proxy.";
    exit 1
fi
################################

echo "Install NodeJS package has completed!"
