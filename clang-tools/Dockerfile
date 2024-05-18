FROM spacedot/deploy-base AS final
ARG CLANG_TOOLS_VERSION_TAG
ARG CLANG_HTML_VERSION_TAG
RUN apt-get update && apt-get install --yes clang-tools clang-tidy clang
RUN pip3 install clang-html==${CLANG_HTML_VERSION_TAG} --break-system-packages
