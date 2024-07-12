#!/bin/bash

echo -e "Installing NPM Packages"
npm install -g configurable-http-proxy npm@10.8.2

echo -e "Installing pre-builds"
pip install --upgrade pip setuptools wheel manimlib pycairo
pip install -r ./.global/pip_packages.txt

echo -e "Installing IBM-Q Packages"
python3 -m build --verbose --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation ./.global/ext-pkg/ibm-q-labs/ibm_q_lab_server_extension
python3 -m build --verbose --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation ./.global/ext-pkg/ibm-q-labs/ibm_q_lab_ui_extensions
python3 -m build --verbose --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation ./.global/ext-pkg/ibm-q-labs/ibm_quantum_widgets
python3 -m build --verbose --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation ./.global/ext-pkg/ibm-q-labs/ibmq_jupyter_server_health_ext
python3 -m build --verbose --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation ./.global/ext-pkg/ibm-q-labs/qiskit-kernel
pip install ./.global/ext-pkg/*.whl --ignore-installed --no-deps

echo -e "Disabling the classic mode"
jupyter lab build
jupyter labextension enable @jupyterlab/extensionmanager-extension
jupyter labextension enable @jupyterlab/help-extension:launch-classic
jupyter labextension update --all

echo -e "Cleaning up caches..."
apt autoremove -y
apt-get clean
pip cache purge
