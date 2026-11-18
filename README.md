# blackpill-f411ce
A Podman container providing a complete Zephyr development environment for the blackpill-f411ce board.
The development environment is configured according to the [Getting Started Guide](https://docs.zephyrproject.org/latest/develop/getting_started/index.html) and includes the following components:

* [Zephyr v4.5.0](https://github.com/zephyrproject-rtos/zephyr)
* [Zephyr SDK v1.01](https://docs.zephyrproject.org/latest/develop/toolchains/zephyr_sdk.html)
* [Zephyr Workbench](https://docs.zephyrproject.org/latest/develop/tools/workbench_for_zephyr.html)
* [STM32CubeClt](https://www.st.com/en/development-tools/stm32cubeclt.html)
* [Ubuntu 26.04](https://ubuntu.com/)

Notes:

* Read [HOWTO.md](file://.devcontainers/stm32cubeclt/HOWTO.md) for instructions on obtaining Debian packages required to build the container.<br>
  Also, remember to update the version numbers of these packages in the [Containerfile](file://Containerfile).
