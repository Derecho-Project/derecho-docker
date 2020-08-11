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
git clone https://github.com/grpc/grpc.git
cd grpc
git checkout 9dfbd34
# use proxy to bypass GFW for git submodule install
export http_proxy=10.0.0.252:12333
export https_proxy=10.0.0.252:12333
git submodule update --init --recursive
make -j `lscpu | grep "^CPU(" | awk '{print $2}'`
make install
