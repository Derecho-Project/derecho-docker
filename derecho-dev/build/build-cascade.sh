#!/bin/bash

INSTALL_PREFIX="/usr/local"

git clone --recursive https://<UserName>:<Password>@github.com/Derecho-Project/cascade.git
cd cascade

mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ..
make -j `lscpu | grep "^CPU(" | awk '{print $2}'`
make install