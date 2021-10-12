FROM debian:bullseye-slim AS base
WORKDIR /root/

RUN apt-get update
RUN apt-get install --yes --no-install-recommends cmake git

FROM base AS doxygen-build-env

ARG DOXYGEN_VERSION_TAG

RUN apt-get install --yes --no-install-recommends build-essential ca-certificates python3 checkinstall
RUN apt-get install --yes --no-install-recommends flex bison
RUN apt-get install --yes --no-install-recommends libxml2-utils # to run the test suite
RUN git clone --depth 1 --branch Release_$(echo ${DOXYGEN_VERSION_TAG} | sed 's/\./\_/g') https://github.com/doxygen/doxygen.git
WORKDIR doxygen/build
RUN cmake .. 
RUN make -j$(nproc)
# doxygen needs it for its testing to complete
RUN apt-get --yes --no-install-recommends install texlive
RUN make tests
RUN checkinstall --type=debian --pkgname=doxygen --pkgversion=${DOXYGEN_VERSION_TAG} \
		--pkgrelease="CUSTOM" --provides=doxygen --requires="" make install

FROM base AS doxygen-awesome-css-build-env

ARG DOXYGEN_VERSION_TAG

RUN apt-get install --yes --no-install-recommends ca-certificates checkinstall
RUN git clone --depth 1 --branch v${DOXYGEN_AWESOME_CSS_VERSION_TAG} https://github.com/jothepro/doxygen-awesome-css.git
RUN tar -czvf doxygen-awesome-css.tar.gz --exclude doxygen-awesome-css/.git --exclude doxygen-awesome-css/.github doxygen-awesome-css/

# FINAL IMAGE
FROM base AS final
COPY --from=doxygen-build-env /root/doxygen/build/*.deb .
COPY --from=doxygen-awesome-css-build-env /root/*.tar.gz .

# Install everything
RUN apt install --yes --no-install-recommends ./*.deb && \
		tar -vzxf *.tar.gz && rm *.tar.gz
