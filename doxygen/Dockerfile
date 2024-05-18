FROM spacedot/build-base AS doxygen-awesome-css-build-env

ARG DOXYGEN_AWESOME_CSS_VERSION_TAG

RUN git clone --depth 1 --branch v${DOXYGEN_AWESOME_CSS_VERSION_TAG} https://github.com/jothepro/doxygen-awesome-css.git
RUN tar -czvf doxygen-awesome-css.tar.gz --exclude doxygen-awesome-css/.git --exclude doxygen-awesome-css/.github doxygen-awesome-css/

# FINAL IMAGE
FROM spacedot/deploy-base AS final
ARG DOXYGEN_VERSION_TAG
RUN apt-get update && apt-get install --yes doxygen=${DOXYGEN_VERSION_TAG} graphviz
COPY --from=doxygen-awesome-css-build-env /root/*.tar.gz .

# Install everything
RUN tar -vzxf *.tar.gz && rm *.tar.gz
