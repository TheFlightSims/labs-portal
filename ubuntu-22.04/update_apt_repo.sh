#!/bin/bash

echo -e "Updating local APT Repos"
apt update && apt full-upgrade -y

for i in openssl pwgen git nano nodejs yarn automake gcc \
         g++ gdb make cmake zip libcurl4-gnutls-dev sox \
         librtmp-dev ffmpeg libcairo2 libcairo2-dev pari-gp \
         libgirepository1.0-dev libhdf5-dev python3 \
         python3-pip python3-venv python3-build; do
  apt install -y $i || continue;
done

apt --fix-broken install