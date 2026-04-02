#!/bin/bash
# Script used only in CD pipeline

set -ex

if [[ $(uname -m) == "riscv64" ]]; then
    # Can't build OpenBLAS from sources on riscv64, just use the one from package repositories
    apt-get update -qq
    apt-get install -qq -y --no-install-recommends libopenblas-dev
    apt-get autoclean && apt-get clean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    exit 0
fi

OPENBLAS_VERSION=${OPENBLAS_VERSION:-"v0.3.30"}

# Clone OpenBLAS
git clone https://github.com/OpenMathLib/OpenBLAS.git -b "${OPENBLAS_VERSION}" --depth 1 --shallow-submodules

OPENBLAS_CHECKOUT_DIR="OpenBLAS"
OPENBLAS_BUILD_FLAGS="
CC=gcc
NUM_THREADS=128
USE_OPENMP=1
NO_SHARED=0
DYNAMIC_ARCH=1
TARGET=ARMV8
CFLAGS=-O3
BUILD_BFLOAT16=1
"

make -j8 ${OPENBLAS_BUILD_FLAGS} -C $OPENBLAS_CHECKOUT_DIR
sudo make install -C $OPENBLAS_CHECKOUT_DIR

rm -rf $OPENBLAS_CHECKOUT_DIR