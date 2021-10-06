FROM debian:bullseye-slim AS base
WORKDIR /root/

ARG IKOS_VERSION_TAG

RUN apt-get update
RUN apt-get install --yes --no-install-recommends cmake git


FROM base AS compile-base
RUN apt-get install --yes --no-install-recommends build-essential

FROM compile-base AS ikos-build-env
RUN apt-get install --yes --no-install-recommends gcc g++ cmake libgmp-dev libboost-dev libboost-filesystem-dev \
    libboost-thread-dev libboost-test-dev python3 python3-pygments libsqlite3-dev libtbb-dev \
    libz-dev libedit-dev llvm-9 llvm-9-dev llvm-9-tools clang-9
RUN apt-get install --yes --no-install-recommends ca-certificates checkinstall python3-distutils libmpfr-dev
RUN git clone --depth 1 --branch v${IKOS_VERSION_TAG} https://github.com/NASA-SW-VnV/ikos
WORKDIR ikos
# Python >3.9 changed the function name, updating
RUN sed -i.orig 's/isAlive/is_alive/g' ./analyzer/python/ikos/analyzer.py
RUN cmake -B build -DLLVM_CONFIG_EXECUTABLE="/usr/lib/llvm-9/bin/llvm-config" -DCMAKE_INSTALL_PREFIX="/opt/ikos"
WORKDIR build
RUN make -j$(nproc)
RUN make check -j$(nproc)
# Post install script: Add executables to PATH
RUN printf "#! /bin/bash \ncat <<EOF>> /etc/profile.d/90-ikos.sh\n#! /bin/bash\nexport PATH=\$PATH:/opt/ikos/bin/\nEOF" > postinstall-pak
# Package for final installation
RUN checkinstall --type=debian --pkgname=ikos --pkgversion=${IKOS_VERSION_TAG} --pkgrelease="CUSTOM" \
	--provides=ikos \
	--requires="python3 \(\>= 3.9 \),libgcc-10-dev \(\>= 10.2.1\),libstdc++6 \(\>= 10.2.1\),libsqlite3-0 \(\>= 3.34.1\),libboost-dev \(\>= 1.74.0\),libboost-filesystem-dev \(\>= 1.74.0\),libboost-thread-dev \(\>= 1.74.0\),python3-pygments \(\>= 2.7.1\),libgmpxx4ldbl \(\>= 6.2.1\),libtbb2 \(\>= 2020.3\),zlib1g \(\>= 1.2.11\),llvm-9 \(\>= 9.0.1\),llvm-9-tools \(\>= 9.0.1\),clang-9 \(\>= 9.0.1\),libmpfr6 \(\>= 4.1.0\)" \
	--strip=yes --fstrans=no \
	--default make install


FROM base AS final
WORKDIR /root/
COPY --from=ikos-build-env /root/ikos/build/*.deb .
RUN apt install --yes --no-install-recommends ./*.deb

ENTRYPOINT ["/bin/sh", "-c", ". /etc/profile.d/90-ikos.sh", "-c"]
