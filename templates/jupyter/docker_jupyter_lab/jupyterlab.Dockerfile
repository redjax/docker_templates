ARG UV_BASE=${UV_IMAGE_VER:-0.5.9}
ARG PYTHON_BASE=${PYTHON_IMAGE_VER:-3.12-slim}
ARG NODE_BASE=${NODE_IMAGE_VER:-23-slim}

ARG JUPYTER_LAB_TOKEN=${JUPYTER_LAB_TOKEN:-""}
ARG JUPYTER_LAB_PASSWORD=${JUPYTER_LAB_PASSWORD:-""}
ARG JUPYTER_CONFIG_DIR=${JUPYTER_CONFIG_DIR:-/project/.jupyter/config}
ARG JUPYTER_LAB_CONFIG_DIR=${JUPYTER_LAB_CONFIG_DIR:-/project/.jupyter/lab}
ARG JUPYTER_LAB_SETTINGS_DIR=${JUPYTER_LAB_SETTINGS_DIR:-/project/.jupyter/lab/user-settings}
ARG JUPYTER_DATA_DIR=${JUPYTER_DATA_DIR:-/project/.jupyter/data}
ARG JUPYTER_RUNTIME_DIR=${JUPYTER_RUNTIME_DIR:-/project/.jupyter/runtime}

FROM ghcr.io/astral-sh/uv:${UV_BASE} AS uv
FROM node:${NODE_BASE} AS node
FROM python:${PYTHON_BASE} AS base

COPY --from=uv /uv /usr/bin/uv
COPY --from=node /usr/local/bin/node /usr/bin/node

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    apt-get install -y gcc

FROM base AS stage

WORKDIR /project

COPY pyproject.toml uv.lock README.md ./
# COPY ./src ./src

RUN uv sync --dev --all-extras && \
    uv build && \
    uv pip install -e .

FROM stage AS build_jupyter

ENV JUPYTER_LAB_TOKEN=$JUPYTER_LAB_TOKEN
ENV JUPYTER_LAB_PASSWORD=$JUPYTER_LAB_PASSWORD
ENV JUPYTER_CONFIG_DIR=$JUPYTER_CONFIG_DIR
ENV JUPYTER_LAB_CONFIG_DIR=$JUPYTER_LAB_CONFIG_DIR
ENV JUPYTER_LAB_SETTINGS_DIR=$JUPYTER_LAB_SETTINGS_DIR
ENV JUPYTER_DATA_DIR=$JUPYTER_DATA_DIR
ENV JUPYTER_RUNTIME_DIR=$JUPYTER_RUNTIME_DIR

COPY --from=stage /project /project
COPY --from=base /usr/bin /usr/bin

WORKDIR /project

RUN uv run jupyter lab build

FROM build_jupyter AS run

COPY --from=stage /project /project
COPY --from=base /usr/bin/node /usr/bin/node

WORKDIR /project

CMD ["echo", "hello, world"]

# FROM stage AS run_scripts

# COPY --from=base /project /project

# WORKDIR /project

# COPY scripts /project/scripts
