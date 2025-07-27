#!/bin/bash

echo -e "Installing NPM Packages"
npm install -g configurable-http-proxy

echo -e "Installing pre-builds"
for ins in pip setuptools wheel "manimlib==0.2.0" pycairo; do
    pip install $ins --ignore-installed --default-timeout=360 --use-pep517 || continue;
    if [ $? -ne 0 ]; then 
        echo -e -n "Error while installing $ins. Retrying..."
        pip install $ins --ignore-installed --default-timeout=360 --use-pep517  || continue;
    fi
done

pip install -r ./.global/pip_base.txt --default-timeout=360 --use-pep517

echo -e "Building IBM-Q Packages"
for ibmqpkg in ibm_q_lab_server_extension ibm_q_lab_ui_extensions ibm_quantum_widgets ibmq_jupyter_server_health_ext qiskit-kernel; do
    python3 -m build --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation ./.global/ext-pkg/ibm-q-labs/$ibmqpkg
done

pip install ./.global/ext-pkg/*.whl --ignore-installed --no-deps --use-pep517

echo -e "Disabling the classic mode"
jupyter lab build
jupyter labextension disable @jupyterlab/extensionmanager-extension
