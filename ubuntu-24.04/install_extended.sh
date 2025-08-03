#!/bin/bash

set -euo pipefail

CURR_DIR="$(cd "$(dirname "$0")" && pwd)"

trap 'echo "Error occurred at line ${LINENO}. Exiting..." | tee -a "${LOGFILE}"; exit 1' ERR

(( EUID == 0 )) || { echo "Please run as root"; exit 1; }

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
pip install -r ./.global/pip_extended.txt --default-timeout=360 --break-system-packages
while [ $? -ne 0 ]; do
    echo -e -n "Error while installing extended packages. Retrying...";
    pip install -r ./.global/pip_extended.txt --default-timeout=360 --break-system-packages;
done

# javascript
npm install -g --unsafe-perm ijavascript
ijsinstall --install=global
