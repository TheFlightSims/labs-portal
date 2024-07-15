#!/bin/bash

# javascript
npm install -g --unsafe-perm ijavascript
ijsinstall --install=global

# ilua
apt install -y liblua5.3-0 liblua5.3-0-dbg liblua5.3-dev lua5.3
pip install ilua

# octave kernel
apt install -y python3-octave-kernel

# r-kernel
apt install -y r-cran-irdisplay r-cran-irkernel
