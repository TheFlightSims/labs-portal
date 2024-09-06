#!/bin/bash

# NVIDIA CUDA, AI frameworks, and extended kernels
for i in nvidia-driver-550-server-open cuda-drivers-fabricmanager-550 \
        libcub-dev nvidia-cuda-dev cudnn liblua5.3-0 liblua5.3-0-dbg \
        liblua5.3-dev lua5.3 r-cran-irdisplay r-cran-irkernel \
        python3-octave-kernel; do
  apt install -y $i
  if [ $? -ne 0 ]; then
    echo -e -n "Unable to install $i, retrying..."
    apt update && apt full-upgrade -y && apt --fix-broken install -y && apt install -y $i 
  fi
done

for pkg in $(cat ./.global/pip_extended.txt); do 
  pip install $pkg --ignore-installed --default-timeout=3600 || continue; 
done

# javascript
npm install -g --unsafe-perm ijavascript
ijsinstall --install=global
