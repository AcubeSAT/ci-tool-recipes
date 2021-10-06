CPPCHECK_VERSION_TAG = 2.5

DOXYGEN_VERSION_TAG = 1.9.2
DOXYGEN_AWESOME_CSS_VERSION_TAG = 1.6.0

CLANG_TOOLS_VERSION_TAG = 13.0.0
CLANG_HTML_VERSION_TAG = 1.3.7

GCOVR_VERSION_TAG = 5.0
LCOV_VERSION_TAG = 1.15

IKOS_VERSION_TAG = 3.0

all: cppcheck doxygen clang-tools coverage ikos
	docker push cppcheck:${CPPCHECK_VERSION_TAG}

.PHONY: cppcheck doxygen clang-tools coverage ikos
cppcheck:
	docker build . -f cppcheck/Dockerfile --build-arg CPPCHECK_VERSION_TAG=${CPPCHECK_VERSION_TAG} -t cppcheck:${CPPCHECK_VERSION_TAG}
doxygen:
	docker build . -f doxygen/Dockerfile --build-arg DOXYGEN_VERSION_TAG=${DOXYGEN_VERSION_TAG} --build-arg DOXYGEN_AWESOME_CSS_VERSION_TAG=${DOXYGEN_AWESOME_CSS_VERSION_TAG} -t doxygen:${DOXYGEN_VERSION_TAG}-awesomecss-${DOXYGEN_AWESOME_CSS_VERSION_TAG}
#clang-tools:
#	docker build . -f clang-tools/Dockerfile --build-arg CLANG_TOOLS_VERSION_TAG=${CLANG_TOOLS_VERSION_TAG} --build-arg CLANG_HTML_VERSION_TAG=${CLANG_HTML_VERSION_TAG} -t clang-tools:${CLANG_TOOLS_VERSION_TAG}-html-${CLANG_HTML_VERSION_TAG}
#coverage:
#	docker build . -f coverage/Dockerfile --build-arg GCOVR_VERSION_TAG=${GCOVR_VERSION_TAG} --build-arg LCOV_VERSION_TAG=${LCOV_VERSION_TAG} -t coverage:gcovr-${GCOVR_VERSION_TAG}-lcov-${LCOV_VERSION_TAG}
#ikos:
#	docker build . -f ikos/Dockerfile --build-arg IKOS_VERSION_TAG=${IKOS_VERSION_TAG} -t ikos:${IKOS_VERSION_TAG}
