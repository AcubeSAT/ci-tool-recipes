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

## Guidelines for Creating Images

This section offers an exhaustive guide on best practices for Docker image creation. It's designed to be comprehensive, covering scenarios that may not always apply but are critical for those unique cases.

### Key Principles
- **Version Transparency:** Ensure every dependency's version is inspectable.
- **Minimal Trust Base:** Keep the number of implicitly trusted sources small.

### Image Creation Process
1. **Debian Bookworm Availability:**
  - Check if the tool is available in Debian Bookworm.
  - Use the Debian package if available; otherwise, proceed to build from source.

2. **Building from Source:**
  - Acquire the specific source code version.
  - Build with Debian's dependencies, adding any missing compatible versions as needed.
  - Avoid direct `apt update` calls in Dockerfiles for reproducibility.

3. **Testing and Packaging:**
  - Run available unit tests, documenting any deviations or issues.
  - Use `checkinstall` for packaging into `.deb` files.
  - Document the tool's version and any custom dependencies.

4. **Final Assembly:**
  - In a separate Docker build stage, `COPY` and install all `.deb` files.
  - Push only after you've tested the image locally.

### Special Considerations for Python Packages
- Find the `requirements.txt`/`pyproject.toml` and identify which python packages can be installed through Debian.
Prefer Debian Python packages; resort to `pip` only when necessary.
- Document any deviations from Debian packages, including the rationale.

---

## Issues

### Docker Hub Tag Precedence Issue

This section addresses a conflict between local Docker images and their counterparts on Docker Hub due to tag precedence.

#### Overview
- **Local vs. Docker Hub Tags:** Local base images (`build-base` and `deploy-base`) are also pushed to Docker Hub with specific tags.
- **Tagging Format:** In Dockerfiles, these images are referred to with shorthand tags (like `spacedot/build-base`), which Docker interprets as Docker Hub tags (`docker.io/spacedot/build-base`).

#### Problem
- **Unexpected Pulling from Docker Hub:** When building Docker images, Docker may pull these base images from Docker Hub instead of using the locally prepared versions.
- **Inconsistencies in Build Process:** This can lead to the use of outdated or different versions of base images than intended, affecting the reliability and consistency of the build process.

#### Impact
- The behavior can cause discrepancies in the Docker image building process, potentially leading to issues with stability and version control.

#### Resolution Strategy
- Ensure clear and distinct tagging for local images to prevent overlap with Docker Hub tags.
- Regularly synchronize local and Docker Hub tags to maintain consistency across builds.


---

## Additional Best Practices

- **Layer Optimization:** Combine related commands to reduce image layers.
- **Documentation:** Maintain clear and detailed documentation for each stage of the image building process, including rationale for specific decisions.

## License
The contents of this repo are licensed under the MIT license. Please make sure you comply with
each tool's license separately.
