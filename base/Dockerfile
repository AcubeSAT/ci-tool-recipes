FROM debian:bookworm-slim AS base
FROM python:3.11-slim-bullseye
WORKDIR /root/

RUN apt-get update
RUN apt-get install --yes --no-install-recommends binutils cmake make python3-pygments ca-certificates

FROM base AS build-base
RUN apt install --yes --no-install-recommends git build-essential checkinstall \
		python3-pytest python3-setuptools libxml2-utils libz3-dev ninja-build
RUN pip3 install conan

FROM base AS deploy-base
RUN apt install --yes --no-install-recommends git build-essential checkinstall \
    python3-pytest python3-setuptools libxml2-utils libz3-dev python3-lxml libgcc-12-dev python3-pip
RUN pip3 install conan
