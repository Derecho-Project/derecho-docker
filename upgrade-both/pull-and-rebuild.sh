#!/bin/bash

INSTALL_PREFIX="/usr/local"

# pull and rebuild derecho
cd /derecho
git pull

if [ ! -d "build" ]; then
  mkdir build
else
  rm -rf build && mkdir build
fi
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ..
make -j `lscpu | grep "^CPU(" | awk '{print $2}'`
make install

# pull and rebuild cascade
cd /cascade
git pull

if [ ! -d "build" ]; then
  mkdir build
else
  rm -rf build && mkdir build
fi
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ..
make -j `lscpu | grep "^CPU(" | awk '{print $2}'`
make install