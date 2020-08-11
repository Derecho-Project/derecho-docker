#!/bin/bash

INSTALL_PREFIX="/usr/local"

git clone --recursive https://github.com/Derecho-Project/derecho.git
cd derecho

mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ..
make -j `lscpu | grep "^CPU(" | awk '{print $2}'`
make install