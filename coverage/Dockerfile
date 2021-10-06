# CAUTION: gcovr is untested as tests run only on really old gcc (8)

FROM debian:bullseye-slim AS base
WORKDIR /root/

ARG GCOVR_VERSION_TAG
ARG LCOV_VERSION_TAG

RUN apt-get update
RUN apt-get install --yes --no-install-recommends cmake git

FROM base AS gcovr-build-env 
RUN apt-get install --yes --no-install-recommends build-essential checkinstall ca-certificates python3
RUN git clone --depth 1 --branch ${GCOVR_VERSION_TAG} https://github.com/gcovr/gcovr
WORKDIR /root/gcovr

RUN apt-get install --yes --no-install-recommends python3-pytest python3-setuptools python3-lxml python3-pyutilib python3-jinja2 python3-markupsafe python3-pygments
RUN python3 setup.py build
#RUN CC=gcc-10 make test
RUN checkinstall --type=debian --pkgname=gcovr --pkgversion=${GCOVR_VERSION_TAG} --pkgrelease="CUSTOM" \
		--provides=gcovr --requires="python3-pygments \(\>= 2.7.1\),python3 \(\>= 3.9.2\),python3-lxml \(\>= 4.6.3\),python3-jinja2 \(\>= 2.11.3\),python3-markupsafe \(\>= 1.1.1\)" --default --fstrans=no python3 setup.py install

FROM base AS lcov-build-env
RUN apt-get install --yes --no-install-recommends checkinstall ca-certificates gcc
RUN git clone --depth 1 --branch v${LCOV_VERSION_TAG} https://github.com/linux-test-project/lcov
WORKDIR /root/lcov
RUN make check
RUN checkinstall --type=debian --pkgname=lcov --pkgversion=${LCOV_VERSION_TAG} --pkgrelease="CUSTOM" \
		--provides=lcov --requires="perl \(\>= 5.32.1\),gcc \(\>= 10.2.1\)" --default make install

# FINAL IMAGE
FROM base AS final
COPY --from=gcovr-build-env /root/gcovr/*.deb .
COPY --from=lcov-build-env /root/lcov/*.deb .
# Install everything
RUN apt install --yes --no-install-recommends ./*.deb 

# Start a new shell
ENTRYPOINT ["/bin/sh", "-c"]
