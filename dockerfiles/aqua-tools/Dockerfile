## Build arguments for version control
ARG PYTHON_VERSION=3.13
ARG AQUA_INSTALLER_VERSION=v4.0.4
ARG AQUA_VERSION=v2.55.3

FROM python:${PYTHON_VERSION}-slim-bookworm

# https://github.com/aquaproj/aqua-installer/releases
ARG AQUA_INSTALLER_VERSION=v4.0.4
# https://github.com/aquaproj/aqua/releases
ARG AQUA_VERSION=v2.56.7

## Install minimal system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    neovim \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

## Install aqua CLI
RUN curl -sSfL "https://raw.githubusercontent.com/aquaproj/aqua-installer/${AQUA_INSTALLER_VERSION}/aqua-installer" | \
    bash -s -- -v "${AQUA_VERSION}"

## Configure aqua paths and global config
ENV PATH="/root/.local/share/aquaproj-aqua/bin:/root/.local/bin:${PATH}" \
    AQUA_ROOT_DIR="/root/.local/share/aquaproj-aqua" \
    AQUA_GLOBAL_CONFIG="/root/.config/aquaproj-aqua/aqua.yaml"

## Copy aqua configuration to global location
COPY aqua.yaml /root/.config/aquaproj-aqua/aqua.yaml

## Copy config files
COPY config/ /root/.config/

## Copy Python tools installation script
COPY scripts/install-python-tools.sh /usr/local/bin/install-python-tools.sh
RUN dos2unix /usr/local/bin/install-python-tools.sh && \
    chmod +x /usr/local/bin/install-python-tools.sh

## Install all tools globally from aqua.yaml
RUN --mount=type=secret,id=github_token \
    if [ -f /run/secrets/github_token ]; then \
        export GITHUB_TOKEN="$(cat /run/secrets/github_token)"; \
    fi && \
    aqua install --all

## Install Python-based tools
RUN /usr/local/bin/install-python-tools.sh

## Set up shell environment
RUN echo 'export PATH="/root/.local/share/aquaproj-aqua/bin:/root/.local/bin:${PATH}"' >> /root/.bashrc && \
    echo 'eval "$(atuin init bash --disable-up-arrow)"' >> /root/.bashrc && \
    echo 'eval "$(direnv hook bash)"' >> /root/.bashrc

## Set working directory
WORKDIR /workspace

## Default to bash shell
CMD ["/bin/bash"]
