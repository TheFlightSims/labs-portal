#!/bin/bash

echo -e "Installing NPM Packages"
npm install -g configurable-http-proxy

echo -e "Installing pre-builds"
for ins in pip setuptools wheel pycairo; do
    pip install $ins --ignore-installed --default-timeout=360 || continue;
done

for pkg in $(cat ./.global/pip_base.txt); do 
    pip install $pkg --ignore-installed --default-timeout=360 || continue; 
done

echo -e "Installing IBM-Q Packages"
python3 -m build --verbose --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation ./.global/ext-pkg/ibm-q-labs/ibm_q_lab_server_extension
python3 -m build --verbose --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation ./.global/ext-pkg/ibm-q-labs/ibm_q_lab_ui_extensions
python3 -m build --verbose --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation ./.global/ext-pkg/ibm-q-labs/ibm_quantum_widgets
python3 -m build --verbose --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation ./.global/ext-pkg/ibm-q-labs/ibmq_jupyter_server_health_ext
python3 -m build --verbose --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation ./.global/ext-pkg/ibm-q-labs/qiskit-kernel
pip install ./.global/ext-pkg/*.whl --ignore-installed --no-deps

echo -e "Disabling the classic mode"
jupyter lab build
jupyter labextension disable @jupyterlab/extensionmanager-extension
