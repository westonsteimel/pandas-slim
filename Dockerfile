# For some reason using `pip download` with the `--python-version`
# option does not find the most recent version of pandas for 
# the lowest supported python version (currently 3.7) so we use that as base
# image

FROM python:3.7-slim

RUN apt update \
    && apt install -y \
    zip \
    pcregrep \
    binutils \
    bash

WORKDIR /build

COPY slimify.sh /build/

CMD ["/build/slimify.sh"]
