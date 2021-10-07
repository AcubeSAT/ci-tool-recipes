# AcubeSAT CI tools

## Purpose
This repository contains Docker images for each of the testing tools used in our CI pipelines.
Built images are being published in Docker Hub, under `spacedot/<folder-name>:<tool-version>`.


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

IMPORTANT 

## License
The contents of this repo are licensed under the MIT license. Please make sure you comply with
each tool's license separately.
