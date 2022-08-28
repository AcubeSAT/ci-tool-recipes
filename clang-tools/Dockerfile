FROM spacedot/build-base AS clang-build-env

ARG CLANG_TOOLS_VERSION_TAG

RUN git clone --depth 1 --branch llvmorg-${CLANG_TOOLS_VERSION_TAG} https://github.com/llvm/llvm-project
WORKDIR /root/llvm-project/build
RUN cmake ../llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang-tools-extra;clang" \
		-DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_BUILD_TESTS=ON -DLLVM_ENABLE_Z3_SOLVER=ON -GNinja
RUN ninja -j$(nproc) clang-tidy scan-build scan-view clang
# too much memory for full nproc jobs (> 8 GiB)
RUN ninja -j$(($(nproc) - 2)) check-clang-extra-clang-tidy check-clang-analysis
RUN checkinstall -type=debian --pkgname=clang-tidy --pkgversion=${CLANG_TOOLS_VERSION_TAG} \
		--pkgrelease="CUSTOM" --provides=clang-tidy --requires="libz3-4 \(\>= 4.8.10\)" \
		ninja install-clang-tidy-stripped
RUN checkinstall -type=debian --pkgname=clang-static-analysis --pkgversion=${CLANG_TOOLS_VERSION_TAG} \
		--pkgrelease="CUSTOM" --provides=clang-static-analysis --requires="libz3-4 \(\>= 4.8.10\),python3 \(\>= 3.9.2\)" \
		ninja install-clang-stripped install-clang-resource-headers-stripped install-scan-build-stripped install-scan-view-stripped

FROM spacedot/build-base as clang-html-build-env

ARG CLANG_HTML_VERSION_TAG

RUN apt-get update
RUN apt-get install --yes --no-install-recommends python3-lxml python3-bs4
RUN git clone --depth 1 --branch v${CLANG_HTML_VERSION_TAG} https://github.com/austinbhale/Clang-Visualizer
WORKDIR Clang-Visualizer
RUN checkinstall -type=debian --pkgname=clang-tidy-html --pkgversion=${CLANG_HTML_VERSION_TAG} \
		--pkgrelease="CUSTOM" --provides=clang-tidy-html --requires="python3-lxml \(\>= 4.6.3\),python3-bs4 \(\>= 4.7.1\)" \
		--fstrans=no --default \
		python3 setup.py install

# FINAL IMAGE
FROM spacedot/deploy-base AS final
COPY --from=clang-build-env /root/llvm-project/build/*.deb .
COPY --from=clang-html-build-env /root/Clang-Visualizer/*.deb .

# Install everything
# perl, libfindbin-libs-perl: used by CMake for building (Needed wherever actual build configuration will happen thru CMake)
# libc-dev, libgcc-10-dev, libstdc++-10-dev are needed because Clang itself was compiled with GCC (10.x as of 19/10/2021)
# and thus is not "standalone". This shouldn't matter because here it is used only as a static analysis tool,
# not for compiling real programs. Proper bootstrapping will take hours to build, and needs a strong PC.
# TODO when GitLab takes the brunt of building and deployment itself.
RUN apt install --yes --no-install-recommends ./*.deb libc-dev libstdc++-10-dev perl libfindbin-libs-perl
