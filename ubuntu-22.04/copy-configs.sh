#!/bin/bash

echo -e "Copying configurations"
mkdir /etc/labs_portal/

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

echo -e "Installing Login Web Templates..."
rm -rf /usr/local/share/jupyterhub/*
mkdir /usr/local/share/jupyterhub/static
mkdir /usr/local/share/jupyterhub/templates
cp -TRv ./.global/web-portal/hub-login /usr/local/share/jupyterhub

echo -e "Coping tutorial notebooks into global folder..."
mkdir /etc/labs_portal/tutorials-notebooks
cp -TRv ./.global/tutorials-notebooks /etc/labs_portal/tutorials-notebooks
chmod 740 /etc/labs_portal/tutorials-notebooks
