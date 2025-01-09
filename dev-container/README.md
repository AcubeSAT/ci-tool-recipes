##Dev Container
To avoid installing the dependencies manually, or install any packages locally, we provide a dev container.
You can still interact with the project in the usual way, but all dependencies will be installed in the container.
**Reminder:** To correctly clone git repos through conan, you'll need to set the SSH key in the container.

### VSCode
You can install the dev-containers extension from the marketplace. It should automatically detect the `devcontainer.json` file in the projects root directory.

### Cursor
Cursor doesn't support dev-containers extension yet. To use the dev-container, you can need to:
1. Install the dev-container CLI by running `npm install -g devcontainer`
1. Run `devcontainer build --workspace-folder .` in the terminal in the project root directory.
1. Run `devcontainer up --workspace-folder .` in the terminal in the project root directory.
1. To get into the container's shell, run `devcontainer exec --workspace-folder . /bin/bash`.

### CLion
Follow the instructions [from the CLion Documentation - Start Dev Container Inside IDE](https://www.jetbrains.com/help/clion/start-dev-container-inside-ide.html)

Everything should be ready to go from there. Follow the build instructions & run the in the container.