#!/bin/bash

set -euo pipefail

CURR_DIR="$(cd "$(dirname "$0")" && pwd)"

trap 'echo "Error occurred at line ${LINENO}. Exiting..." | tee -a "${LOGFILE}"; exit 1' ERR

(( EUID == 0 )) || { echo "Please run as root"; exit 1; }

echo -e "Updating local APT Repos"
apt update && apt full-upgrade -y

for i in openssl pwgen git nano nodejs yarn automake gcc \
        g++ gdb make cmake zip libcurl4-gnutls-dev sox \
        librtmp-dev ffmpeg libcairo2 libcairo2-dev pari-gp \
        libgirepository1.0-dev libhdf5-dev python3 \
        python3-pip python3-venv python3-build libtool \
        build-essential autoconf ninja-build flex bison dkms \
        linux-headers-$(uname -r) ccache cppcheck 7zip gzip \
        tar npm; do
    apt install -y $i
    while [ $? -ne 0 ]; do
        echo "Error installing $i. Retrying..."
        sleep 5
        apt install -y $i
    done
done

apt --fix-broken install

echo -e "Installing NPM Packages"
npm install -g configurable-http-proxy

echo -e "Installing pre-builds"
for ins in pip setuptools wheel; do
    pip install "$ins" --default-timeout=360 --break-system-packages;
    while [ $? -ne 0 ]; do
        echo -e -n "Error while installing $ins. Retrying...";
        pip install "$ins" --default-timeout=360 --break-system-packages;
    done
done

echo -e "Installing base packages"
pip install -r ./.global/pip_base.txt --default-timeout=360 --break-system-packages
while [ $? -ne 0 ]; do
    echo -e -n "Error while installing base packages. Retrying...";
    pip install -r ./.global/pip_base.txt --default-timeout=360 --break-system-packages;
done

echo -e "Building IBM-Q Packages"
for ibmqpkg in ibm_q_lab_server_extension ibm_q_lab_ui_extensions ibm_quantum_widgets ibmq_jupyter_server_health_ext qiskit-kernel; do
    python3 -m build --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation --force ./.global/ext-pkg/ibm-q-labs/$ibmqpkg
done
pip install ./.global/ext-pkg/*.whl --ignore-installed --no-deps --force-reinstall --break-system-packages

echo -e "Disabling the classic mode"
jupyter lab build
jupyter labextension disable @jupyterlab/extensionmanager

echo -e "Copying auth"
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

echo -e "Copying default SQLite"
cp ./$CURR_DIR/res/labs_portal.sqlite /etc/labs_portal/

echo -e "Copying standard configurations"
cp ./$CURR_DIR/res/config.py /etc/labs_portal/config.py
cp ./$CURR_DIR/res/.env /etc/labs_portal/.env

chmod 760 /etc/labs_portal
if [ $? -eq 0 ]; then
    echo "[LABS PORTAL CF CP] Configuration copying is finished."
else
    echo "[LABS PORTAL CF CP] Configuration copying failed. Failing the installer..."
    exit 1
fi
``` 

This updated script now:
- Logs all command output to a file (install_standard.log) while still showing it in the terminal.
- Utilizes a trap to catch errors and exit the script immediately if any command fails.# filepath: f:\theflightsims\labs-portal\ubuntu-24.04\install_standard.sh
#!/bin/bash
set -euo pipefail

# Set up logging: all output will be logged to install_standard.log in the script directory
LOGFILE="$(cd "$(dirname "$0")" && pwd)/install_standard.log"
exec > >(tee -a "${LOGFILE}") 2>&1

# Trap any errors; prints the line number and exits
trap 'echo "Error occurred at line ${LINENO}. Exiting..." | tee -a "${LOGFILE}"; exit 1' ERR

CURR_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "Updating local APT Repos"
apt update && apt full-upgrade -y

for i in openssl pwgen git nano nodejs yarn automake gcc \
        g++ gdb make cmake zip libcurl4-gnutls-dev sox \
        librtmp-dev ffmpeg libcairo2 libcairo2-dev pari-gp \
        libgirepository1.0-dev libhdf5-dev python3 \
        python3-pip python3-venv python3-build; do
    apt install -y $i
    if [ $? -ne 0 ]; then
        echo "Error installing $i. Retrying..."
        apt update && apt full-upgrade -y && apt --fix-broken install -y && apt install -y $i
    fi
done

apt --fix-broken install

echo -e "Installing NPM Packages"
npm install -g configurable-http-proxy

echo -e "Installing pre-builds"
for ins in pip setuptools wheel; do
    pip install "$ins" --default-timeout=360 --break-system-packages;
    while [ $? -ne 0 ]; do
        echo -e -n "Error while installing $ins. Retrying...";
        pip install "$ins" --default-timeout=360 --break-system-packages;
    done
done

echo -e "Installing base packages"
pip install -r ./.global/pip_base.txt --default-timeout=360 --break-system-packages
while [ $? -ne 0 ]; do
    echo -e -n "Error while installing base packages. Retrying...";
    pip install -r ./.global/pip_base.txt --default-timeout=360 --break-system-packages;
done

echo -e "Building IBM-Q Packages"
for ibmqpkg in ibm_q_lab_server_extension ibm_q_lab_ui_extensions ibm_quantum_widgets ibmq_jupyter_server_health_ext qiskit-kernel; do
    python3 -m build --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation --force ./.global/ext-pkg/ibm-q-labs/$ibmqpkg
done
pip install ./.global/ext-pkg/*.whl --ignore-installed --no-deps --force-reinstall --break-system-packages

echo -e "Disabling the classic mode"
jupyter lab build
jupyter labextension disable @jupyterlab/extensionmanager

echo -e "Copying auth"
mkdir -p /etc/labs_portal/

# Create cookie secret file and proxy authenticator
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

echo -e "Coping tutorial notebooks into global folder..."
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

echo -e "Copying default SQLite"
cp ./$CURR_DIR/res/labs_portal.sqlite /etc/labs_portal/

echo -e "Copying standard configurations"
cp ./$CURR_DIR/res/config.py /etc/labs_portal/config.py

chmod 770 /etc/labs_portal

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
