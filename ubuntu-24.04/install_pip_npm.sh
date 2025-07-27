#!/bin/bash

echo -e "Installing NPM Packages"
npm install -g configurable-http-proxy

echo -e "Installing pre-builds"
for ins in pip setuptools wheel manimlib pycairo; do
    pip install "$ins" --default-timeout=360 --break-system-packages;
    if [ $? -ne 0 ]; then 
        echo -e -n "Error while installing $ins. Retrying...";
        pip install "$ins" --default-timeout=360 --break-system-packages;
    fi
done

echo -e "Installing base packages"
while IFS= read -r pkg; do
    
    if [[ -z "$pkg" || "$pkg" =~ ^# ]]; then
        continue
    fi

    pip install "$pkg" --default-timeout=360 --break-system-packages
done < ./.global/pip_base.txt

echo -e "Building IBM-Q Packages"
for ibmqpkg in ibm_q_lab_server_extension ibm_q_lab_ui_extensions ibm_quantum_widgets ibmq_jupyter_server_health_ext qiskit-kernel; do
    python3 -m build --wheel --outdir ./.global/ext-pkg --skip-dependency-check --no-isolation --force ./.global/ext-pkg/ibm-q-labs/$ibmqpkg
done
pip install ./.global/ext-pkg/*.whl --ignore-installed --no-deps --force-reinstall --break-system-packages

echo -e "Disabling the classic mode"
jupyter lab build
jupyter labextension disable @jupyterlab/extensionmanager