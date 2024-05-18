# CAUTION: gcovr is untested as tests run only on really old gcc (8)

FROM spacedot/deploy-base AS final

ARG GCOVR_VERSION_TAG

RUN pip install gcovr==${GCOVR_VERSION_TAG} --break-system-packages

ARG LCOV_VERSION_TAG

RUN apt-get update && apt-get -y install lcov
