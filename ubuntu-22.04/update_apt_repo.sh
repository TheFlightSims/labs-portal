#!/bin/bash

echo -e "Updating local APT Repos"
apt update && apt full-upgrade -y

for i in openssl pwgen netcat git nano nodejs yarn automake \
         gcc g++ gdb make cmake zip libcurl4-gnutls-dev \
         librtmp-dev sox ffmpeg libcairo2 libcairo2-dev \
         libgirepository1.0-dev libhdf5-dev pari-gp python3 \
         python3-pip python3-venv python3-build; do
  apt install -y $i
done

apt --fix-broken install