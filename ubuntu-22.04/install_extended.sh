#!/bin/bash

# NVIDIA CUDA and AI frameworks
for i in nvidia-driver-550-server-open cuda-drivers-fabricmanager-550 \
        libcub-dev nvidia-cuda-dev cudnn; do
  apt install -y $i
done

for pkg in $(cat ./.global/pip_extended.txt); do 
  pip install $pkg --ignore-installed --default-timeout=360 || continue; 
done

# javascript
npm install -g --unsafe-perm ijavascript
ijsinstall --install=global

# ilua
for i in liblua5.3-0 liblua5.3-0-dbg liblua5.3-dev lua5.3; do apt install -y $i; done
pip install ilua

# octave kernel
apt install -y python3-octave-kernel

# r-kernel
for i in r-cran-irdisplay r-cran-irkernel; do apt install -y $i; done
