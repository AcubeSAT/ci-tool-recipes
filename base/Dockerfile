FROM debian:bookworm-slim AS base
WORKDIR /root/

RUN apt-get update
RUN apt-get install --yes --no-install-recommends binutils cmake make python3 python3-pygments ca-certificates

FROM base AS build-base
RUN apt install --yes --no-install-recommends git build-essential checkinstall \
		python3-pytest python3-setuptools libxml2-utils libz3-dev ninja-build python3-pip
RUN checkinstall --version
RUN pip install conan --break-system-packages

FROM base AS deploy-base
RUN apt install --yes --no-install-recommends git build-essential checkinstall \
     python3-pytest python3-setuptools libxml2-utils libz3-dev python3-lxml libgcc-12-dev python3-pip
RUN pip install conan --break-system-packages

