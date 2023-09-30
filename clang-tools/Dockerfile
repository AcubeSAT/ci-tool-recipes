FROM spacedot/build-base as clang-html-build-env

ARG CLANG_HTML_VERSION_TAG

RUN apt-get update && apt-get install --yes --no-install-recommends python3-lxml python3-bs4 python3-certifi
RUN git clone --depth 1 --branch v${CLANG_HTML_VERSION_TAG} https://github.com/austinbhale/Clang-Visualizer
WORKDIR Clang-Visualizer
RUN checkinstall -type=debian --pkgname=clang-tidy-html --pkgversion=${CLANG_HTML_VERSION_TAG} \
		--pkgrelease="CUSTOM" --provides=clang-tidy-html --requires="python3-lxml \(\>= 4.6.3\),python3-bs4 \(\>= 4.7.1\),python3-certifi \(\>= 2020.6.20\)" \
		--fstrans=no --default \
		python3 setup.py install

# FINAL IMAGE
FROM spacedot/deploy-base AS final
ARG CLANG_TOOLS_VERSION_TAG
RUN apt-get update && apt-get install --yes clang-tools clang-tidy
COPY --from=clang-html-build-env /root/Clang-Visualizer/*.deb ./

# Install everything
# perl, libfindbin-libs-perl: used by CMake for building (Needed wherever actual build configuration will happen thru CMake)
# libc-dev, libgcc-10-dev, libstdc++-10-dev are needed because Clang itself was compiled with GCC (10.x as of 19/10/2021)
# and thus is not "standalone". This shouldn't matter because here it is used only as a static analysis tool,
# not for compiling real programs. Proper bootstrapping will take hours to build, and needs a strong PC.
# TODO when GitLab takes the brunt of building and deployment itself.
RUN apt update && apt install --yes --no-install-recommends ./*.deb libc-dev libstdc++-12-dev perl libfindbin-libs-perl
RUN apt-get update && apt-get install clang
