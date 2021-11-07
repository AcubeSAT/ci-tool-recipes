FROM spacedot/build-base AS doxygen-build-env

ARG DOXYGEN_VERSION_TAG

RUN apt-get install --yes --no-install-recommends flex bison texlive # texlive: needed to run doxygen's testsuite
RUN git clone --depth 1 --branch Release_$(echo ${DOXYGEN_VERSION_TAG} | sed 's/\./\_/g') https://github.com/doxygen/doxygen.git
WORKDIR doxygen/build
RUN cmake .. -GNinja 
RUN make -j$(nproc)
RUN make tests
RUN checkinstall --type=debian --pkgname=doxygen --pkgversion=${DOXYGEN_VERSION_TAG} \
		--pkgrelease="CUSTOM" --provides=doxygen --requires="" make install

FROM spacedot/build-base AS doxygen-awesome-css-build-env

ARG DOXYGEN_AWESOME_CSS_VERSION_TAG

RUN git clone --depth 1 --branch v${DOXYGEN_AWESOME_CSS_VERSION_TAG} https://github.com/jothepro/doxygen-awesome-css.git
RUN tar -czvf doxygen-awesome-css.tar.gz --exclude doxygen-awesome-css/.git --exclude doxygen-awesome-css/.github doxygen-awesome-css/

# FINAL IMAGE
FROM spacedot/deploy-base AS final
COPY --from=doxygen-build-env /root/doxygen/build/*.deb .
COPY --from=doxygen-awesome-css-build-env /root/*.tar.gz .

# Install everything
RUN apt install --yes --no-install-recommends ./*.deb && \
		tar -vzxf *.tar.gz && rm *.tar.gz
