FROM debian:bullseye-slim AS base
WORKDIR /root/

RUN apt-get update
RUN apt-get install --yes --no-install-recommends cmake make

FROM base AS build-base
RUN apt-get install --yes --no-install-recommends git build-essential ca-certificates checkinstall

FROM base AS deploy-base
RUN apt-get install --yes --no-install-recommends binutils
