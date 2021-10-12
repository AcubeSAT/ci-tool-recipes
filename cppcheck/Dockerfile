FROM debian:bullseye-slim AS base
WORKDIR /root/

RUN apt-get update
RUN apt-get install --yes --no-install-recommends cmake git

FROM base AS cppcheck-build-env

ARG CPPCHECK_VERSION_TAG
# Build cppcheck (rundeps: pcre for rules, python for misra)
# PCRE is recommended for rules, python3 is for misra checker and build optimizations
RUN apt-get install --yes --no-install-recommends build-essential checkinstall ca-certificates libpcre3-dev \
		python3 python3-pytest python3-setuptools python3-pygments tidy libxml2-utils

RUN git clone --depth 1 --branch ${CPPCHECK_VERSION_TAG} https://github.com/danmar/cppcheck
WORKDIR /root/cppcheck/build
RUN cmake .. -DHAVE_RULES=ON -DUSE_MATCHCOMPILER=ON -DBUILD_TESTS=ON -DCMAKE_BUILD_TYPE=Release
RUN make -j$(nproc)

# Test cppcheck itself, the MISRA plugin and cppcheck-htmlreport
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10
RUN make test # run test suite
WORKDIR /root/cppcheck
RUN PYTHONPATH=addons python3 -m pytest addons/test/test-misra.py # run misra tests
RUN ln -s ./build/bin/cppcheck ./cppcheck # prepare for cppcheck-htmlreport test
WORKDIR /root/cppcheck/htmlreport/
RUN bash check.sh

# Pack everything up if all tests went ok (fstrans=no: reason is https://superuser.com/a/1386314)
WORKDIR /root/cppcheck/htmlreport
RUN checkinstall --type=debian --pkgname=cppcheck-htmlreport --pkgversion=${CPPCHECK_VERSION_TAG} \
		--pkgrelease="CUSTOM" --provides=cppcheck-htmlreport --requires="python3-pygments \(\>= 2.7.1\)" --fstrans=no --pakdir=/root/cppcheck/build/ python3 setup.py install

WORKDIR /root/cppcheck/build
RUN checkinstall --type=debian --pkgname=cppcheck --pkgversion=${CPPCHECK_VERSION_TAG} --pkgrelease="CUSTOM" \
		--provides=cppcheck --requires="libpcre3 \(\>= 8.39\),python3 \(\>= 3.9.2\)" --default

# FINAL IMAGE
FROM base AS final
COPY --from=cppcheck-build-env /root/cppcheck/build/*.deb .

# Install everything
RUN apt install --yes --no-install-recommends ./*.deb 
