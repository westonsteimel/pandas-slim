#!/bin/bash

set -e

PIP_DOWNLOAD_CMD="pip download --no-deps --disable-pip-version-check"

mkdir -p dist

(
    cd dist

    if [[ -z "${PANDAS_VERSION}" ]]; then
        echo "Set the PANDAS_VERSION environment variable."
        exit 1
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
            \*/\conftest.py

        wheel unpack $filename
        find pandas-${PANDAS_VERSION}/ -name "*.so" | xargs strip
        rm $filename
        wheel pack pandas-${PANDAS_VERSION}

        rm -r pandas-${PANDAS_VERSION}
    done

    pip uninstall -y --disable-pip-version-check pandas
    pip install \
        --disable-pip-version-check \
        --index-url https://westonsteimel.github.io/pypi-repo \
        "pandas-${PANDAS_VERSION}-cp37-cp37m-manylinux1_x86_64.manylinux_2_5_x86_64.whl"
)

python test.py
