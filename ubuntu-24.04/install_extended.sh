#!/bin/bash

set -euo pipefail
trap 'echo "Error occurred at line ${LINENO} of ${BASH_SOURCE[0]}. Exiting..."; exit 1' ERR

CURR_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

for i in cuda-drivers-fabricmanager-550 libcub-dev \
          nvidia-cuda-dev liblua5.3-0 liblua5.3-0-dbg \
          liblua5.3-dev lua5.3 r-cran-irdisplay \
          r-cran-irkernel python3-octave-kernel; do
  apt install -y $i
  while [ $? -ne 0 ]; do
    echo -e -n "Unable to install $i, retrying..."
    sleep 5
    apt install -y $i
  done
done

echo -e "Installing extended Python packages"
pip install -r ./.global/pip_extended.txt --default-timeout=300 --break-system-packages --ignore-installed
while [ $? -ne 0 ]; do
    echo -e -n "Error while installing extended packages. Retrying...";
    pip install -r ./.global/pip_extended.txt --default-timeout=360 --break-system-packages --ignore-installed;
done

# javascript
npm install -g --unsafe-perm ijavascript
ijsinstall --install=global
