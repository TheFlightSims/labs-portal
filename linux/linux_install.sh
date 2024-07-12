#!/bin/bash

echo -e "Copying default SQLite"
cp ./linux/res/jupyterhub.sqlite /etc/jupyter/

echo -e "Copying standard configurations"
cp ./linux/res/config.py /etc/jupyter/config.py

chmod 700 /etc/jupyter
