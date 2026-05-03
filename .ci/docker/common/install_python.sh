#!/bin/bash
set -ex

apt-get update
# Use deadsnakes in case we need an older python version
# sudo add-apt-repository ppa:deadsnakes/ppa
apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-dev python3-pip python${PYTHON_VERSION}-venv

# Use a venv because uv and some other package managers don't support --user install
ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python
python -m venv /var/lib/jenkins/ci_env
source /var/lib/jenkins/ci_env/bin/activate

if which ccache 2>/dev/null; then
    export CC="ccache gcc"
    export CXX="ccache g++"
    export FC="ccache gfortran"
fi

python -mpip install --upgrade pip
python -mpip install -r /opt/requirements-ci.txt
