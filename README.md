# AcubeSAT CI tools

## Purpose
This repository contains Docker images for each of the testing tools used in our CI pipelines.
Built images are being published in Docker Hub, under `spacedot/<folder-name>:<tool-version>`.

## Image Heritage
All images are based on Debian buster, and the programs within are built from source against
distro dependencies. Regression tests are run where possible (see table) before packaging.
A dependency is built from source only if one of the following happens:

- It is not available in distro repos at all
- It is available but in a different major version than the one specified by the program's
vendor as tested, in which case the exact version is built from source against distro
dependencies.

No patching is done to program source code itself. Patches may be applied to "peripheral" code
(e.g launcher scripts) to make them compatible with breakage (e.g. ikos has one such small patch
because Python removed a feature from one minor version to another). In any case, the program
shall pass its test suite after any patch.

## Image contents and notes
| **Image Name** | **Contents**                                                                                                                  | **Regression Tests Run**      | **Notes**                                       |
|----------------|-------------------------------------------------------------------------------------------------------------------------------|-------------------------------|-------------------------------------------------|
| base           | CMake, Git                                                                                                                    | No (distro packages - tested) |                                                 |
| clang-tools    | clang-tidy, clang-static-analyzer, scan-build, scan-view, [clang-visualizer](https://github.com/austinbhale/Clang-Visualizer) | Yes for all                   |                                                 |
| coverage       | gcovr, lcov                                                                                                                   | lcov only - TODO gcovr        |                                                 |
| cppcheck       | cppcheck (with MISRA checker), cppcheck-htmlreport                                                                            | Yes for all                   |                                                 |
| doxygen        | doxygen, [doxygen-awesome-css](https://github.com/jothepro/doxygen-awesome-css)                                               | Yes for all                   |                                                 |
| ikos           | [ikos](https://github.com/NASA-SW-VnV/ikos)                                                                                   | Yes for all                   | Trivially patched launch script-see Dockerfile. |


## How to use
In case an update to a tool is published, change the appropriate variable in `.gitlab-ci.yml`
in a separate branch. GitLab will attempt to build each image, and will also run the test suites
of each tool. If the build is successful, open a merge request and someone will check and update
the tool if everything is OK.

If you want to introduce a new tool, add its Dockerfile within a subdirectory of the repo and
create a build stage and appropriate version variable in `.gitlab-ci.yml`.
See the already-existing Dockerfiles as a guideline.

**IMPORTANT NOTE:** As of 07/10/2021 GitLab does *not* support propagating build arguments
(ARG lines) declared in a "top-level" image of a multi-stage build to the images based on
that top-level image. Please make sure you declare build arguments exactly at the stage they
are needed for the image to be built successfully.

The `master` branch of this repository is always buildable.

## License
The contents of this repo are licensed under the MIT license. Please make sure you comply with
each tool's license separately.
