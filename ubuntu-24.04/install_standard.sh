#!/bin/bash

set -euo pipefail

CURR_DIR="$(cd "$(dirname "$0")" && pwd)"

trap 'echo "Error occurred at line ${LINENO} of ${BASH_SOURCE[0]}. Exiting..."; exit 1' ERR

(( EUID == 0 )) || { echo "Please run as root"; exit 1; }

echo -e "Updating local APT Repos"
apt update && apt full-upgrade -y

for i in openssl pwgen git nano nodejs yarn automake gcc \
        g++ gdb make cmake zip libcurl4-gnutls-dev sox \
        librtmp-dev ffmpeg libcairo2 libcairo2-dev pari-gp \
        libgirepository1.0-dev libhdf5-dev python3 python3-pip \
        python3-venv python3-build python3-setuptools \
        python3-wheel libtool build-essential autoconf \
        linux-headers-$(uname -r) ccache cppcheck 7zip gzip \
        tar npm flex bison dkms ninja-build; do
    apt install -y $i
    while [ $? -ne 0 ]; do
        echo "Error installing $i. Retrying..."
        sleep 5
        apt install -y $i
    done
done

echo -e "Installing NPM Packages"
npm install -g configurable-http-proxy

echo -e "Installing base packages"
pip install -r ./.global/pip_base.txt --default-timeout=360 --break-system-packages --ignore-installed
while [ $? -ne 0 ]; do
    echo -e -n "Error while installing base packages. Retrying...";
    pip install -r ./.global/pip_base.txt --default-timeout=360 --break-system-packages --ignore-installed;
done

mkdir -p /etc/labs_portal/

echo -e "Creating authenticator"
touch /etc/labs_portal/proxy_auth_token
chown :sudo /etc/labs_portal/proxy_auth_token
chmod g+rw /etc/labs_portal/proxy_auth_token
openssl rand -hex 32 > /etc/labs_portal/proxy_auth_token
touch /etc/labs_portal/cookie_secret
chown :sudo /etc/labs_portal/cookie_secret
chmod g+rw /etc/labs_portal/cookie_secret
openssl rand -hex 32 > /etc/labs_portal/cookie_secret
chmod 600 /etc/labs_portal/cookie_secret
chmod 600 /etc/labs_portal/proxy_auth_token

echo -e "Creating SSL certificate"
mkdir -p /etc/labs_portal/ssl
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout /etc/labs_portal/ssl/labs_portal.key \
    -out /etc/labs_portal/ssl/labs_portal.crt \
    -subj "/C=US/ST=FL/L=Miami/O=TheFlightSims/CN=localhost"
echo -e "Setting permissions for SSL certificate"
chmod 600 /etc/labs_portal/ssl/labs_portal.key
chmod 644 /etc/labs_portal/ssl/labs_portal.crt

echo -e "Copying tutorial notebooks into global folder..."
mkdir -p /etc/labs_portal/tutorials-notebooks
cp -TRv ./.global/tutorials-notebooks /etc/labs_portal/tutorials-notebooks
chmod 740 /etc/labs_portal/tutorials-notebooks

echo -e "Installing Login Web Templates..."
rm -rf /usr/local/share/jupyterhub/*
mkdir -p /etc/labs_portal/web
mkdir -p /etc/labs_portal/web/extensions && mkdir -p /etc/labs_portal/web/base
ln -s /etc/labs_portal/web/base/templates /usr/local/share/jupyterhub/templates
ln -s /etc/labs_portal/web/base/static /usr/local/share/jupyterhub/static
cp -TRv ./.global/web-portal/hub-login /etc/labs_portal/web/base

echo -e "Copying standard configurations"
cp ./$CURR_DIR/res/config.py /etc/labs_portal/config.py
cp ./$CURR_DIR/res/.env /etc/labs_portal/.env

chmod 700 /etc/labs_portal
if [ $? -eq 0 ]; then
    echo "[LABS PORTAL CF CP] Configuration copying is finished."
else
    echo "[LABS PORTAL CF CP] Configuration copying failed. Failing the installer..."
    exit 1
fi

echo -e "Installing labs_portal service..."
cat <<EOF | tee /etc/systemd/system/labs_portal.service
[Unit]
Description=Labs Portal JupyterHub Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/etc/labs_portal
ExecStart=/usr/bin/python3 jupyterhub -f /etc/labs_portal/config.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable labs_portal
echo -e "Labs Portal service installed and started successfully."
