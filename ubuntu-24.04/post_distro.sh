#!/bin/bash

################################
# Error handing
set -euo pipefail
trap 'echo "Error occurred at line ${LINENO} of ${BASH_SOURCE[0]}. "; exit 1' ERR
################################

################################
# Running some checks
if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi
################################

################################
# Enable Systemd service
if [ ps --no-headers -o comm 1 | grep -q systemd ]; then
    echo -e "Installing labs_portal service..."
    cat <<EOF | tee /etc/systemd/system/labs-portal.service
[Unit]
Description=Labs Portal Service
After=network.target

[Service]
Type=simple
WorkingDirectory=/etc/labs-portal
ExecStart=/usr/bin/python3 jupyterhub -f /etc/labs-portal/config.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload && systemctl enable labs-portal
    if [ $? -ne 0 ]; then
        echo -e "Unable to enable Labs Portal service.\nYou can use: systemctl start labs-portal to start the service.\n"
    else
        echo "Labs Portal service installed and started successfully."
    fi
fi

# Clean-up pacakges
apt autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
if [ $? -ne 0 ]; then
    echo "Failed to clean-up apt packages"
fi

conda clean --all -y
if [ $? -ne 0 ]; then
    echo "Failed to clean-up conda packages"
fi
################################

echo "Post installation for distro has been completed!"
