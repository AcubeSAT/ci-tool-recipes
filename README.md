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

### Guidelines for creating images

Note: This is a really long section, and most of the time there's no need to follow everything
stated here, just a small, relevant part. It is meant to be reasonably exhaustive, and drive
home what one should need to take care when they need to do something that is not covered here.

The pipeline was designed with the following requirements:
- anyone should be able to inspect the versions of the entire million dependencies that make
  up the tools 
- keep the trust base (aka the number of sources that are trusted implicitly) small.

These requirements are upheld in the following ways:

- use `apt` for documenting versions, keeping stuff clean and compatible
- build everything not included already in Debian from source,
- anything not already in Debian should have a known version.

Therefore, to add a new tool/thing/whatever, the following process **must** be adhered to:

1. Check if your tool is available in Debian buster itself in the major version you want.
(Buster is old, TODO: run the pipeline against current debian and test that)

*If it's there*: cool! fetch the Debian version and use that. e.g. say you want to use Python 3.
Debian has it, so you use it as is.

*If it's not there*: cool! go to step 2. Note that all actions on step 2 should be done as a
separate build step in Docker, whose input must be only an `ARG` with the version and its
output one or more .deb packages with documented versions and dependencies.

2. Get the source code of the thing you want at the major version you want, 
and build that using Debian's dependencies.

Say you want to use gcc 12 for some reason. Debian buster has 8.3, so it's not suitable.
This means:

a) Get source for gcc 12.x (latest gcc 12.x but nevertheless a specific version). 
b) Try building it. Use Debian's packages at your disposal to complete the build if
any are needed. If there is a dependency you need that's not available in Debian itself
in a compatible version, fetch the correct version's source and build that, recursively.

**IMPORTANT NOTE**: Your package should be buildable against the latest packages from Debian
`buster`, but your Dockerfile **must never call apt update directly!** The pipeline's first
stage fetches the latest package list at the time of building, and gets timestamped for
reproducibility. Calling `apt update` anywhere outside the base images will possibly result
in your target image having different package list from the base image, thus invalidating
the guarantee that versions are known in every stage of the pipeline. **Images calling for
update in the middle of the pipeline WILL be rejected.**

c) After building the main thing you want (or it's dependency, if you do this recursively)
run its unit tests if they are available. If for any reason you can't run the unit tests,
*find out why and document it*. They should all pass.
**Don't include a tool or dependency that has broken unit tests without knowing
why said tests break and either fixing or documenting the breakage.**
d) When the unit tests pass, try running your tool yourself to see if it works.
e) Package the final binaries up with `checkinstall` (see the other Dockerfiles to see how,
it's a oneliner usually). This process should be done for everything not from Debian, whether
a library or your main tool. Document the tool's main version and its dependencies (either
Debian-sourced or custom deb files you made with the recursive process).

If you did this correctly, you should end up with one or more .deb packages.
One of them is the main tool, the others are it's dependencies that are not available in Debian.
*Everything must depend*:
- only on Debian packages
- OR the custom debs made in the process.

3. *In a separate Docker build stage*, `COPY` all produced debs and install them with `apt install`.
This will install all stuff needed from Debian at the correct versions,
and the packages themselves.

4. Test the final image (the one produced by apt installing all the debs).
If all's OK, push the dockerfile to the repo and it should be included. 

#### Note for Python packages

In case you have Python stuff to include, check its requirements.txt file, or if that's not available,
one of setup.cfg or setup.py or pyproject.toml to find:
- either a path to requirements.txt (yes it's that messy, sorry) or 
- a set of package names and version constraints.

As soon as you have that, do an honest attempt (aka don't immediately give up) searching in Debian
packages for python-<yourpackagename> or python3-<yourpackagename> usually, to see if Debian has it.
*If it does*, prefer that instead of using pip, as Debian includes most of the popular Python packages,
but if it doesn't and following through the dep tree is too hard, just add them from pip
and let people know.

This is a known weakness, but Python (and in general most languages with a package manager) doesn't
play well with distros packaging up their libraries, making the trust base shrinking some times
not worth the bother.


## Issues

**Docker Hub tags take precedence over local images**
Local images (specifically build-base and deploy-base) that are reused to create all images of this repo,
if pushed to Docker Hub under the same tag as the one pulled as part of the Dockerfiles, will result in
building all tools with bases different than the latest.

For example: GitLab needs Docker images to be tagged with form "registry-1.docker.io/spacedot/:" in order
to be pushed to Docker Hub. However, the Dockerfiles use `FROM spacedot/build-base` and
`FROM spacedot/deploy-base` which are shorthand for docker.io/spacedot/build-base and
docker.io/spacedot/deploy-base.

This difference is significant (technically they are different tags) and as a result,
Docker tries to pull the tags from Docker Hub, not the prepared ones from the previous stages.

## License
The contents of this repo are licensed under the MIT license. Please make sure you comply with
each tool's license separately.
