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
git clone https://github.com/protocolbuffers/protobuf.git
cd protobuf
git submodule update --init --recursive
./autogen.sh
./configure --prefix=${INSTALL_PREFIX}
make -j `lscpu | grep "^CPU(" | awk '{print $2}'`
make install
ldconfig
