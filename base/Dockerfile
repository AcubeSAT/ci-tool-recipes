FROM debian:bookworm-slim AS base
WORKDIR /root/

RUN apt-get update && apt-get install --yes --no-install-recommends binutils cmake make python3 python3-pygments ca-certificates

FROM base AS build-base
ARG CONAN_VERSION_TAG
RUN apt-get update && apt install --yes --no-install-recommends git build-essential checkinstall \
		python3-pytest python3-setuptools libxml2-utils libz3-dev ninja-build python3-pip \
          gcc-arm-none-eabi gdb-arm-none-eabi
RUN pip install conan==${CONAN_VERSION_TAG} --break-system-packages

FROM base AS deploy-base
ARG CONAN_VERSION_TAG
RUN apt-get update && apt install --yes --no-install-recommends git build-essential checkinstall \
     python3-pytest python3-setuptools libxml2-utils libz3-dev python3-lxml libgcc-12-dev python3-pip
RUN pip install conan==${CONAN_VERSION_TAG} --break-system-packages

