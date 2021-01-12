#!/bin/bash

set -e

pip install -U pip==20.2.4

PIP_DOWNLOAD_CMD="pip download --no-deps --disable-pip-version-check"

mkdir -p dist

(
    cd dist

    if [[ -z "${PANDAS_VERSION}" ]]; then
        PANDAS_VERSION=$(pip search pandas | pcregrep -o1 -e "^pandas \((.*)\).*$")
    fi

    echo "slimming wheels for pandas version ${PANDAS_VERSION}"
    
    $PIP_DOWNLOAD_CMD --python-version 3.9 --platform manylinux1_x86_64 pandas==${PANDAS_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux1_x86_64 pandas==${PANDAS_VERSION}
    
    # We can't specify `--python-version` for the 3.7 version because there is some strange bug which prevents
    # it from finding the latest version of pandas in this case
    $PIP_DOWNLOAD_CMD --platform manylinux1_x86_64 pandas==${PANDAS_VERSION}

    for filename in ./*.whl
    do
        zip -d ${filename} \
            \*tests/\* \
            \*testing/\*

        wheel unpack $filename
        find pandas-${PANDAS_VERSION}/ -name "*.so" | xargs strip
        wheel pack pandas-${PANDAS_VERSION}

        rm -r pandas-${PANDAS_VERSION}
    done

    pip uninstall -y --disable-pip-version-check pandas
    pip install \
        --disable-pip-version-check pandas==${PANDAS_VERSION} \
        -f . \
        --index-url https://westonsteimel.github.io/pypi-repo \
        --extra-index-url https://pypi.org/pypi

    python -c "
import importlib
import pandas as pd

module = importlib.import_module('pandas')
print(module.__version__)
"
)
