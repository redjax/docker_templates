# ollama_webui <!-- omit in toc -->

Ollama LLM with [OpenWebUI](https://github.com/open-webui/open-webui) container

## Description <!-- omit in toc -->

Runs a chat webUI with embedded Ollama. The `open-webui` container and `ollama` are both meant to run completely offline. Run your own private chatbot and stop training corporations' models for free.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Usage](#usage)
  - [Installing NVIDIA GPU drivers](#installing-nvidia-gpu-drivers)
  - [Quickstart](#quickstart)
  - [Docker Compose](#docker-compose)
  - [Adding Ollama models](#adding-ollama-models)
  - [Performance tweaks](#performance-tweaks)
    - [Improve response speed time](#improve-response-speed-time)
- [Links](#links)

## Usage

### Installing NVIDIA GPU drivers

Run one of the scripts in the [`scripts/graphics_drivers/`](./scripts/graphics_drivers/) path to install the NVIDIA container toolkit & GPU drivers on the host, and enable GPU passthrough to containers.

### Quickstart

Use a `docker run` command to get started:

```shell
docker run -d -p 3000:8080 --gpus=all -v ollama:/root/.ollama -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama
```

If you are going to run the container this way long term, you should also run a `watchtower` container to keep the webUI up to date:

```shell
docker run --rm --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --run-once open-webui
```

### Docker Compose

There are multiple possible configurations for ollama + open-webui, including ollama on host with open-webui in a container, an all-in-one with ollama and open-webui in the same container, ollama and open-webui in separate containers, supporting GPU instead of CPU, etc.

As of now, only NVIDIA GPU enabled containers are supported.

After [installing the NVIDIA GPU drivers](#installing-nvidia-gpu-drivers), bring up the stack with:

```shell
docker compose -f nvidia.compose.yml up -d
```

This will take a little while, but will bring up ollama with NVIDIA GPU support and an open-webui on port `3000` (by default, set `OPENWEBUI_PORT` to something different if you want to change the web UI port).

### Adding Ollama models

The `ollama` container starts without any models. To add models, find one on [the ollama.com website](https://ollama.com/search) and execute it in the container. You can run the [`install_ollama_model.sh`](./scripts/install_ollama_model.sh) script to be prompted for a model name, and let the script execute the Docker command. You can also just run `docker compose exec`.

For example, to add the `dolphin-mistral` model with:

```shell
docker compose exec -it open-webui /bin/bash -c "ollama run dolphin-mistral"
```

Some models I've found useful:

- [qwq](https://ollama.com/library/qwq)
- [dolphin-mistral](https://ollama.com/library/dolphin-mistral)
- [dolphin-mixtral](https://ollama.com/library/dolphin-mixtral)

### Performance tweaks

#### Improve response speed time

[Source](https://github.com/open-webui/open-webui/discussions/7821#discussioncomment-11641870)

If responses from the LLM are slow, try switching off `"Retrieval Query Generation"`, `"Tags Generation"`, and `"Autocomplete Generation"` in the web UI. These configurations can be found by opening `Admin Panel` -> `Settings` -> `Interface`.

Restart both Ollama and Open-WebUI after making this change.

## Links

- [Open-webui documentation](https://docs.openwebui.com/getting-started/)
- [Install Nvidia container toolkit](https://gist.github.com/GurucharanSavanth/ee67321a63975e1c26e0765e2561ae9d#install-docker-and-nvidia-container-toolkit)
- [open-webui default setup](https://github.com/open-webui/open-webui#installation-with-default-configuration)
- [Installing open-webui with bundled ollama](https://github.com/open-webui/open-webui#installing-open-webui-with-bundled-ollama-support)
