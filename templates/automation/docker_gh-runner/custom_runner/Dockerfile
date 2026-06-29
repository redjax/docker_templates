ARG BASE_IMG=${CONTAINER_BASE_IMAGE:-ubuntu:24.04}
ARG RUNNER_VERSION=${GH_RUNNER_VERSION:-2.294.0}

FROM ${BASE_IMG} AS base

ARG RUNNER_VERSION
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && \
    apt upgrade -y && \
    useradd -m docker

RUN apt install -y --no-install-recommends \
    curl \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    libicu-dev \
    liblttng-ust1 \
    libkrb5-3 \
    zlib1g

RUN cd /home/docker && \
    mkdir actions-runner && \
    cd actions-runner && \
    curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzvf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && \
    /home/docker/actions-runner/bin/installdependencies.sh

COPY ./scripts/start.sh start.sh

## Make script executable
RUN chmod +x start.sh

## The config & run script cannot be run as root. Use non-root user
USER docker

ENTRYPOINT ["./start.sh"]
