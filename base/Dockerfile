FROM debian:bullseye-slim AS base
WORKDIR /root/

RUN apt-get update
RUN apt-get install --yes --no-install-recommends binutils cmake make python3 python3-pygments ca-certificates

FROM base AS build-base
RUN apt-get install --yes --no-install-recommends git build-essential checkinstall \
		python3-pytest python3-setuptools libxml2-utils libz3-dev ninja-build

FROM base AS deploy-base
RUN apt-get install --yes --no-install-recommends python3-lxml libgcc-10-dev python3-pip && \
    pip install conan
