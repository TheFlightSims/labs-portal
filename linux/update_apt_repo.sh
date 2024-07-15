#!/bin/bash

echo -e "Updating local APT Repos"
./linux/reset_cache_to_install_node.sh
apt install -y openssl pwgen netcat git nano nodejs yarn
apt install -y gcc g++ gdb make cmake automake zip \
    libcurl4-gnutls-dev librtmp-dev sox ffmpeg libcairo2 \
    libcairo2-dev libgirepository1.0-dev libhdf5-dev pari-gp \
    nvidia-driver-550-server-open cuda-drivers-fabricmanager-550 \
    libcub-dev nvidia-cuda-dev
apt install -y python3 python3-pip python3-venv python3-build
apt --fix-broken install 
