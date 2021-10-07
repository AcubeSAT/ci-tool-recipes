# Contents: clang (for static analyzer), scan-build, scan-view, clang-tidy
# Reporters: scan-view (HTML reports for clang static analyzer)
# Reporters: https://github.com/austinbhale/Clang-Visualizer (clang-tidy HTML reports)
# TODO: use lto where possible, replace make with ninja
FROM debian:bullseye-slim AS base
WORKDIR /root/

RUN apt-get update
RUN apt-get install --yes --no-install-recommends cmake git

FROM base AS clang-build-env

ARG CLANG_TOOLS_VERSION_TAG

RUN apt-get install --yes --no-install-recommends checkinstall ca-certificates build-essential libz3-dev python3
RUN git clone --depth 1 --branch llvmorg-${CLANG_TOOLS_VERSION_TAG} https://github.com/llvm/llvm-project
WORKDIR /root/llvm-project/build
RUN cmake ../llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang-tools-extra;clang" \
		-DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_BUILD_TESTS=ON -DLLVM_ENABLE_Z3_SOLVER=ON
RUN make -j$(nproc) clang-tidy scan-build scan-view clang
# too much memory for full nproc jobs (> 8 GiB)
RUN make -j$(($(nproc) - 2)) check-clang-extra-clang-tidy check-clang-analysis
RUN checkinstall -type=debian --pkgname=clang-tidy --pkgversion=${CLANG_TOOLS_VERSION_TAG} \
		--pkgrelease="CUSTOM" --provides=clang-tidy --requires="libz3-4 \(\>= 4.8.10\)" \
		make install-clang-tidy-stripped
RUN checkinstall -type=debian --pkgname=clang-static-analysis --pkgversion=${CLANG_TOOLS_VERSION_TAG} \
		--pkgrelease="CUSTOM" --provides=clang-static-analysis --requires="libz3-4 \(\>= 4.8.10\),python3 \(\>= 3.9.2\)" \
		make install-clang-stripped install-scan-build-stripped install-scan-view-stripped

FROM base as clang-html-build-env

ARG CLANG_HTML_VERSION_TAG

RUN apt-get install --yes --no-install-recommends ca-certificates python3-setuptools checkinstall python3-lxml python3-bs4
RUN git clone --depth 1 --branch v${CLANG_HTML_VERSION_TAG} https://github.com/austinbhale/Clang-Visualizer
WORKDIR Clang-Visualizer
RUN checkinstall -type=debian --pkgname=clang-tidy-html --pkgversion=${CLANG_HTML_VERSION_TAG} \
		--pkgrelease="CUSTOM" --provides=clang-tidy-html --requires="python3-lxml \(\>= 4.6.3\),python3-bs4 \(\>= 4.7.1\)" \
		--fstrans=no --default \
		python3 setup.py install

# FINAL IMAGE
FROM base AS final
COPY --from=clang-build-env /root/llvm-project/build/*.deb .
COPY --from=clang-html-build-env /root/Clang-Visualizer/*.deb .

# Install everything
RUN apt install --yes --no-install-recommends ./*.deb

ENTRYPOINT ["/bin/sh", "-c"]
