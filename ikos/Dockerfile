FROM build-base AS ikos-build-env

ARG IKOS_VERSION_TAG
RUN apt-get install software-properties-common --yes
RUN apt-add-repository "deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-16 main"
RUN apt-get update

RUN apt-get install --yes --no-install-recommends libgmp-dev libboost-dev libboost-filesystem-dev \
    libboost-thread-dev libboost-test-dev libsqlite3-dev libtbb-dev \
    libz-dev libedit-dev python3-distutils llvm-14 llvm-14-dev llvm-14-tools clang-14 libmpfr-dev
#RUN git clone --depth 1 --branch v${IKOS_VERSION_TAG} https://github.com/NASA-SW-VnV/ikos
#WORKDIR ikos
# Python >3.9 changed the function name, updating
#RUN sed -i.orig 's/isAlive/is_alive/g' ./analyzer/python/ikos/analyzer.py

#RUN cmake -B build -DLLVM_CONFIG_EXECUTABLE="/usr/lib/llvm-14/bin/llvm-config" -DCMAKE_INSTALL_PREFIX=/usr/ -GNinja
#WORKDIR build
#RUN ninja -j$(nproc)
#RUN ninja check -j$(nproc)
#RUN checkinstall --type=debian --pkgname=ikos --pkgversion=${IKOS_VERSION_TAG} --pkgrelease="CUSTOM" \
#	--provides=ikos \
#	--requires="python3 \(\>= 3.9 \),libgcc-10-dev \(\>= 10.2.1\),libstdc++6 \(\>= 10.2.1\),libsqlite3-0 \(\>= 3.34.1\),libboost-dev \(\>= 1.74.0\),libboost-filesystem-dev \(\>= 1.74.0\),libboost-thread-dev \(\>= 1.74.0\),python3-pygments \(\>= 2.7.1\),libgmpxx4ldbl \(\>= 6.2.1\),libtbb2 \(\>= 2020.3\),zlib1g \(\>= 1.2.11\),llvm-9 \(\>= 9.0.1\),llvm-9-tools \(\>= 9.0.1\),clang-9 \(\>= 9.0.1\),libmpfr6 \(\>= 4.1.0\),file \(\>= 5.39\)" \
#	--strip=yes --fstrans=no \
#	--default ninja

#FROM deploy-base AS final
WORKDIR /root/
#COPY --from=ikos-build-env /root/ikos/build/*.deb .
#RUN apt install --yes --no-install-recommends ./*.deb wget curl
RUN apt-get update && apt-get install -y git curl binutils clang make
RUN git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew \
&& mkdir ~/.linuxbrew/bin \
&& ln -s ../Homebrew/bin/brew ~/.linuxbrew/bin \
&& eval $(~/.linuxbrew/bin/brew shellenv) \
&& brew --version && brew install nasa-sw-vnv/core/ikos
ENV PATH="/root/.linuxbrew/bin:${PATH}"
RUN ikos

