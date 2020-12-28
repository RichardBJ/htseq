#!/bin/bash
#
# Build manylinux wheels for HTSeq. Based on the example at
# <https://github.com/pypa/python-manylinux-demo>
#
# It is best to run this in a fresh clone of the repository!
#
# Run this within the repository root:
#   docker run --rm -v $(pwd):/io quay.io/pypa/manylinux2010_x86_64 /io/buildwheels.sh
#
# The wheels will be put into the wheelhouse/ subdirectory.
#
# For interactive tests:
#   docker run -it -v $(pwd):/io quay.io/pypa/manylinux2010_x86_64 /bin/bash

set -xeuo pipefail

# For convenience, if this script is called from outside of a docker container,
# it starts a container and runs itself inside of it.
if ! grep -q docker /proc/1/cgroup; then
  # We are not inside a container
  exec docker run --rm -v $(pwd):/io quay.io/pypa/manylinux2010_x86_64 /io/$0
fi

# Install zlib dev libraries for HTSlib when needed
# manylinux2010 is CentOS 6
yum -y install zlib-devel bzip2-devel xz-devel wget

# Install SWIG (CentOS 6 has an old one!)
wget http://springdale.princeton.edu/data/springdale/6/x86_64/os/Computational/swig3012-3.0.12-3.sdl6.x86_64.rpm
rpm -Uvh swig3012-3.0.12-3.sdl6.x86_64.rpm
yum -y install swig3012

# Python 2.6-3.5 is deprecated
rm -rf /opt/python/cp26*
rm -rf /opt/python/cpython-2.6*
rm -rf /opt/python/cp27*
rm -rf /opt/python/cpython-2.7*
rm -rf /opt/python/cp33*
rm -rf /opt/python/cp34*
rm -rf /opt/python/cp35*

# Build wheels
PYBINS="/opt/python/*/bin"
for PYBIN in ${PYBINS}; do
    echo "PYBIN = ${PYBIN}"

    echo "Install requirements..."
    ${PYBIN}/pip install setuptools wheel Cython matplotlib
    ${PYBIN}/pip install -r /io/requirements.txt

    echo "Build wheels..."
    ${PYBIN}/pip wheel /io/ -w wheelhouse/
done

# Repair HTSeq wheels, copy libraries
for whl in wheelhouse/*.whl; do
    if [[ $whl == wheelhouse/HTSeq* ]]; then
      echo "Repairing wheel: $whl"
      auditwheel repair -L . $whl -w /io/wheelhouse/
    else
      echo "Copying wheel: $whl"
      cp $whl /io/wheelhouse/
    fi
done

# Created files are owned by root, so fix permissions.
chown -R --reference=/io/setup.py /io/wheelhouse/

echo "Build source dist..."
cd /io
${PYBIN}/python setup.py sdist --dist-dir /io/wheelhouse/
echo "Done building"
