#
# Zephyr development image for the STM32F411CE blackpill.
#


# ---------- #
# Base Image #
# ---------- #

# Use Ubuntu 26.04 LTS as base image
FROM ubuntu:26.04

# Build arguments
ARG USER_NAME=zephyr
ARG USER_UID=1000
ARG USER_GID=1000
ARG ZEPHYR_WORKSPACE="/home/${USER_NAME}/blackpill-f411ce"
ARG ZEPHYR_RTOS_BRANCH=v4.5-branch
ARG DEBIAN_FRONTEND=noninteractive

# Copy STM32CubeClt packages
COPY .devcontainer/stm32cubeclt/st-stlink-udev-rules-1.1.0-1-linux-all.deb \
    /tmp/st-stlink-udev-rules-1.1.0-1-linux-all.deb
COPY .devcontainer/stm32cubeclt/st-stlink-server-2.1.1-1-linux-amd64.deb \
    /tmp/st-stlink-server-2.1.1-1-linux-amd64.deb
COPY .devcontainer/stm32cubeclt/stm32cubeclt-1.23.0-29912-20261112-1839-x86_64.deb \
    /tmp/stm32cubeclt-1.23.0-29912-20261112-1839-x86_64.deb
COPY .devcontainer/stm32cubeclt/prompt_linux_license.sh \
    /tmp/prompt_linux_license.sh

# Install base packages (Zephyr RTOS development environment)
RUN apt-get update && \
    LICENSE_ALREADY_ACCEPTED=1 apt-get install -y \
        /tmp/st-stlink-udev-rules-1.1.0-1-linux-all.deb \
        /tmp/st-stlink-server-2.1.1-1-linux-amd64.deb \
        /tmp/stm32cubeclt-1.23.0-29912-20261112-1839-x86_64.deb && \
    apt-get install -y --no-install-recommends \
        sudo \
        cmake \
        ninja-build \
        git \
        gperf \
        ccache \
        dfu-util \
        device-tree-compiler \
        wget \
        python3-dev \
        python3-venv \
        python3-tk \
        xz-utils \
        file \
        make \
        gcc \
        gcc-multilib \
        g++-multilib \
        libsdl2-dev \
        libmagic1 \
        openocd \
        libhidapi-dev \
        curl \
        unzip \
        tar \
        psmisc \
        procps \
        nano && \    
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure default locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create user with password-less sudo and avoid UID/GID conflicts (if any)
RUN set -eux; \
    # On UID conflict, remove default ubuntu user
    if id ubuntu >/dev/null 2>&1; then \
        UBUNTU_UID=$(id -u ubuntu); \
        if [ "${UBUNTU_UID}" = "${USER_UID}" ] && \
           [ "${USER_NAME}" != "ubuntu" ]; then \
            userdel -r ubuntu || true; \
        fi; \
    fi; \
    \
    # On GID conflict, remove default ubuntu group
    if getent group ubuntu >/dev/null; then \
        UBUNTU_GID=$(getent group ubuntu | cut -d: -f3); \
        if [ "${UBUNTU_GID}" = "${USER_GID}" ] && \
           [ "${USER_NAME}" != "ubuntu" ]; then \
            groupdel ubuntu || true; \
        fi; \
    fi; \
    \
    # Reuse group with gid, or create it
    if getent group "${USER_GID}" >/dev/null; then \
        GROUP_NAME=$(getent group "${USER_GID}" | cut -d: -f1); \
    else \
        groupadd --gid "${USER_GID}" "${USER_NAME}"; \
        GROUP_NAME="${USER_NAME}"; \
    fi; \
    \
    # Create user
    useradd \
        --uid "${USER_UID}" \
        --gid "${USER_GID}" \
        --create-home \
        --shell /bin/bash \
        "${USER_NAME}"; \
    \
    # Configure password-less sudo
    usermod -aG sudo "${USER_NAME}"; \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USER_NAME}"; \
    chmod 0440 "/etc/sudoers.d/${USER_NAME}"; \
    \
    # Update prompt colors
    echo "export PS1='\[\e[1;35m\]\u@\h\[\e[0m\]:\[\e[1;35m\]\w\[\e[0m\]\$ '" >> /root/.bashrc; \
    echo "export PS1='\[\e[1;36m\]\u@\h\[\e[0m\]:\[\e[1;36m\]\w\[\e[0m\]\$ '" >> /home/${USER_NAME}/.bashrc; \
    chown "${USER_UID}:${USER_GID}" "/home/${USER_NAME}/.bashrc"; \
    \
    # Create workspace folder
    mkdir -p "${ZEPHYR_WORKSPACE}"; \
    chown -R "${USER_UID}:${USER_GID}" "${ZEPHYR_WORKSPACE}"

# Switch user
USER ${USER_NAME}


# ----------- #
# Zephyr RTOS #
# ----------- #

# Set up Python virtual environment
RUN python3 -m venv ${ZEPHYR_WORKSPACE}/.venv   
ENV PATH="${ZEPHYR_WORKSPACE}/.venv/bin:${PATH}"

# Install Zephyr west tool
RUN pip install --no-cache-dir west

# Install the Zephyr source code, Python dependencies and export CMake package
WORKDIR ${ZEPHYR_WORKSPACE}
RUN west init -m https://github.com/zephyrproject-rtos/zephyr --mr ${ZEPHYR_RTOS_BRANCH} ${ZEPHYR_WORKSPACE} && \   
    west update && \
    west packages pip --install && \
    west zephyr-export

# Install the Zephyr SDK
RUN west sdk install --gnu-toolchains arm-zephyr-eabi


# ------------- #
# Bash Terminal #
# ------------- #
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
CMD ["/bin/bash"]

