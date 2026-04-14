#!/bin/bash

################################
# Error handing
set -euo pipefail
trap 'echo "Error occurred at line ${LINENO} of ${BASH_SOURCE[0]}. "; exit 1' ERR
################################

################################
# Global configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONF_FOLDER="/etc/labs-portal"
JHUB_CONF="/usr/local/share/jupyterhub"
################################

################################
# Running some checks
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

if [[ ! -x "$(which openssl)" ]]; then
    echo "OpenSSL is not installed"
    exit 1
fi
################################

################################
# Prepare Configuration 

cd "$SCRIPT_DIR"

## Creating configuration folder
echo "Creating configuration folder: $CONF_FOLDER"
mkdir -p "$CONF_FOLDER" 
for cnf_folder in ssl tutorials-notebooks web; do
    mkdir -p "$CONF_FOLDER/$cnf_folder"
    if [ $? -ne 0 ]; then
        echo "Unable to create configuration folder: $CONF_FOLDER/$cnf_folder"
        exit 1
    fi
done

## Creating authenticator files
echo "Creating authenticator"
touch "$CONF_FOLDER/proxy_auth_token"
touch "$CONF_FOLDER/cookie_secret"
openssl rand -hex 32 > "$CONF_FOLDER/proxy_auth_token"
openssl rand -hex 32 > "$CONF_FOLDER/cookie_secret"

## Creating certificates
echo -e "Creating SSL certificate"
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -keyout "$CONF_FOLDER/ssl/cert.key" \
    -out "$CONF_FOLDER/ssl/cert.crt" \
    -subj "/C=US/ST=FL/L=Miami/O=TheFlightSims/CN=localhost"
if [ $? -ne 0 ]; then
    echo "Unable to create new certificate. Ignoring..."
fi

## Copy tutorial notebooks
echo -e "Copying tutorial notebooks into global folder..."
cp -TR "$SCRIPT_DIR/../tutorials-notebooks" "$CONF_FOLDER/tutorials-notebooks"

## Copy web templates
echo -e "Installing Login Web Templates..."
rm -rf "$JHUB_CONF/*"
cp -TR "$SCRIPT_DIR/../web-portal/hub-login" "$CONF_FOLDER/web"
ln -s "$CONF_FOLDER/web/templates" "$JHUB_CONF/templates"
ln -s "$CONF_FOLDER/web/base/static" "$JHUB_CONF/static"

## Copy configurations
echo -e "Copying standard configurations"
cp -r "$SCRIPT_DIR/../configurations/*" "$CONF_FOLDER"

## Setting up permissions
chown -R root:sudo "$CONF_FOLDER"
chmod -R 640 "$CONF_FOLDER"

for TOKEN_FILE in proxy_auth_token cookie_secret ssl/cert.key ssl/cert.crt; do
    chown -R root:sudo "$CONF_FOLDER/$TOKEN_FILE"
    chmod -R 640 "$CONF_FOLDER/$TOKEN_FILE"
done

chmod -R 740 "$CONF_FOLDER/tutorials-notebooks"
################################

echo "Copy settings completed!"
