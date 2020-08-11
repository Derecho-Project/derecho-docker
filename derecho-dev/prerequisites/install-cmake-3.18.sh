#!/bin/bash
set -eu
export TMPDIR=/var/tmp
INSTALL_PREFIX="/usr/local"
if [[ $# -gt 0 ]]; then
    INSTALL_PREFIX=$1
fi

echo "Using INSTALL_PREFIX=${INSTALL_PREFIX}"

WORKPATH=`mktemp -d`
cd ${WORKPATH}
wget https://cmake.org/files/v3.18/cmake-3.18.0-rc2-Linux-x86_64.tar.gz
tar xzvf cmake-3.18.0-rc2-Linux-x86_64.tar.gz
mv cmake-3.18.0-rc2-Linux-x86_64 /opt/cmake-3.18.0
ln -sf /opt/cmake-3.18.0/bin/*  ${INSTALL_PREFIX}/bin
cmake --version
