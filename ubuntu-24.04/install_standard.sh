#!/bin/bash

set -euo pipefail
trap 'echo "Error occurred at line ${LINENO} of ${BASH_SOURCE[0]}. Exiting..."; exit 1' ERR

CURR_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCH=$(uname -m)

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

if [ ps --no-headers -o comm 1 | grep -q systemd ]; then
    echo "Systemd detected."
else
    echo "This installer requires systemd. Exiting..."
    exit 1
fi

echo -e "Updating local APT Repos"
apt update && apt full-upgrade -y

for i in openssl pwgen git nodejs npm yarn gcc \
        g++ make cmake zip libtool build-essential \
		autoconf tar gzip nano; do
    apt install -y $i
    while [ $? -ne 0 ]; do
        echo "Error installing $i. Retrying..."
        sleep 5
        apt install -y $i
    done
done

echo -e "Installing Miniconda3"
curl -SL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$ARCH.sh -o /tmp/miniconda.sh
if [ $? -ne 0 ]; then
    echo "Error downloading Miniconda3 installer. Exiting..."
    exit 1
fi

bash /tmp/miniconda.sh -bfp /usr/local
if [ $? -ne 0 ]; then
    echo "Error installing Miniconda3. Exiting..."
    exit 1
fi

rm -rf /tmp/miniconda.sh
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
conda config --add channels conda-forge
conda config --set channel_priority strict

conda install -y python=3
if [ $? -ne 0 ]; then
    echo "Error installing Python 3 via Conda. Exiting..."
    exit 1
fi

echo -e "Installing configurable-http-proxy"
npm i -g configurable-http-proxy --unsafe-perm
while [ $? -ne 0 ]; do
    echo -e -n "Error while installing configurable-http-proxy. Retrying...";
    npm i -g configurable-http-proxy --unsafe-perm;
done

echo -e "Installing base packages"
pip install -r ./.global/pip_base.txt --default-timeout=300 --ignore-installed
while [ $? -ne 0 ]; do
    echo -e -n "Error while installing base packages. Retrying...";
    pip install -r ./.global/pip_base.txt --default-timeout=300 --ignore-installed;
done

conda update --all -y
if [ $? -ne 0 ]; then
    echo "Error updating Conda packages. Exiting..."
    exit 1
fi

conda clean -a -y
if [ $? -ne 0 ]; then
    echo "Warning: Error cleaning Conda cache."
fi

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
cp $CURR_DIR/res/config.py /etc/labs_portal/config.py
cp $CURR_DIR/res/.env /etc/labs_portal/.env

chmod 600 -R /etc/labs_portal

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
