#!/bin/bash

echo -e "Installing Login Web Templates..."
rm -rf /usr/local/share/jupyterhub/*
mkdir /etc/labs_portal/web
mkdir /etc/labs_portal/web/extensions && mkdir /etc/labs_portal/web/base
ln -s /etc/labs_portal/web/base/templates /usr/local/share/jupyterhub/templates
ln -s /etc/labs_portal/web/base/static /usr/local/share/jupyterhub/static
cp -TRv ./.global/web-portal/hub-login /etc/labs_portal/web/base
