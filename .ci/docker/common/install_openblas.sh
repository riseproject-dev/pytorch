#!/bin/bash
# Script used only in CD pipeline

set -ex

if which ccache 2>/dev/null; then
    export CC="ccache gcc"
    export CXX="ccache g++"
    export FC="ccache gfortran"
fi

OPENBLAS_VERSION=${OPENBLAS_VERSION:-"v0.3.30"}
OPENBLAS_CHECKOUT_DIR="OpenBLAS"

if [[ "$BUILD_ENVIRONMENT" == *riscv64* ]]; then
  # FIXME: Once OPENBLAS_VERSION >= v0.3.34, we can enable the following flag
  # https://github.com/OpenMathLib/OpenBLAS/commit/c8dbfd74e2aa40563b11989d16aeb9b3828c16f4
  OPENBLAS_BUILD_BFLOAT16=0 # Requires GCC_VERSION >= 15.2
  OPENBLAS_BUILD_HFLOAT16=0
elif [[ "$BUILD_ENVIRONMENT" == *aarch64* ]]; then
  OPENBLAS_TARGET="ARMV8"
fi

# Clone OpenBLAS
git clone https://github.com/OpenMathLib/OpenBLAS.git -b "${OPENBLAS_VERSION}" --depth 1 --shallow-submodules "${OPENBLAS_CHECKOUT_DIR}"

OPENBLAS_BUILD_FLAGS="
NUM_THREADS=128
USE_OPENMP=1
NO_SHARED=0
DYNAMIC_ARCH=1
TARGET=${OPENBLAS_TARGET}
CFLAGS=-O3
FFLAGS=-Wno-maybe-uninitialized
BUILD_BFLOAT16=${OPENBLAS_BUILD_BFLOAT16:-1}
BUILD_HFLOAT16=${OPENBLAS_BUILD_HFLOAT16:-1}
BUILD_SINGLE=1
BUILD_DOUBLE=1
BUILD_COMPLEX=1
BUILD_COMPLEX16=1
"

make -j8 ${OPENBLAS_BUILD_FLAGS} -C $OPENBLAS_CHECKOUT_DIR
sudo make install ${OPENBLAS_BUILD_FLAGS} -C $OPENBLAS_CHECKOUT_DIR

rm -rf $OPENBLAS_CHECKOUT_DIR
