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
    - [Models I've used](#models-ive-used)
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

You can also use one of the `aio-*.compose.yml` stacks, where `aio` means "all in one" and includes open-webui with ollama bundled.

As of now, only NVIDIA GPU enabled containers are supported.

After [installing the NVIDIA GPU drivers](#installing-nvidia-gpu-drivers), bring up the stack with:

```shell
docker compose -f nvidia.compose.yml up -d
```

This will take a little while, but will bring up ollama with NVIDIA GPU support and an open-webui on port `3000` (by default, set `OPENWEBUI_PORT` to something different if you want to change the web UI port).

### Adding Ollama models

The `ollama` container starts without any models. To add models, find one on [the ollama.com website](https://ollama.com/search) and execute it in the container. If you are not using the default `compose.yml` (i.e. if you have a NVIDIA graphics card and are using the `nvidia.compose.yml` stack), make sure to tell `docker compose` which file to use: `docker compose -f <compose-filename.yml> [docker commands]`.

For example, to add the `dolphin-mistral` model with:

```shell
docker compose exec -it ollama /bin/bash -c "ollama run dolphin-mistral"
```

Or to add the `qwq` model to the `nvidia.compose.yml` stack:

```shell
docker compose -f nvidia.compose.yml exec -it ollama /bin/bash -c "ollama run qwq"
```

#### Models I've used

This is a table of models I've used or would use. The description is taken from [ollama.com](https://ollama.com) for each model.

| Model | Description |
| ----- | ----------- |
| [qwq](https://ollama.com/library/qwq)| QwQ is an experimental research model focused on advancing AI reasoning capabilities. |
| [dolphin-mistral](https://ollama.com/library/dolphin-mistral) | The uncensored Dolphin model based on Mistral that excels at coding tasks. Updated to version 2.8. |
| [dolphin-mixtral](https://ollama.com/library/dolphin-mixtral) | Uncensored, 8x7b and 8x22b fine-tuned models based on the Mixtral mixture of experts models that excels at coding tasks. Created by Eric Hartford. |
| [mistral](https://ollama.com/library/mistral) | The 7B model released by Mistral AI, updated to version 0.3. |
| [starcoder2](https://ollama.com/library/starcoder2) | StarCoder2 is the next generation of transparently trained open code LLMs that comes in three sizes: 3B, 7B and 15B parameters. |
| [wizard-vicuna-uncensored](https://ollama.com/library/wizard-vicuna-uncensored) | Wizard Vicuna Uncensored is a 7B, 13B, and 30B parameter model based on Llama 2 uncensored by Eric Hartford. |
| [magicoder](https://ollama.com/library/magicoder) | 🎩 Magicoder is a family of 7B parameter models trained on 75K synthetic instruction data using OSS-Instruct, a novel approach to enlightening LLMs with open-source code snippets. |
| [dolphincoder](https://ollama.com/library/dolphincoder) | A 7B and 15B uncensored variant of the Dolphin model family that excels at coding, based on StarCoder2. |
| [openhermes](https://ollama.com/library/openhermes) | OpenHermes 2.5 is a 7B model fine-tuned by Teknium on Mistral with fully open datasets. |
| [stable-code](https://ollama.com/library/stable-code) | Stable Code 3B is a coding model with instruct and code completion variants on par with models such as Code Llama 7B that are 2.5x larger. |
| [wizardlm2](https://ollama.com/library/wizardlm2) | State of the art large language model from Microsoft AI with improved performance on complex chat, multilingual, reasoning and agent use cases. |


## Performance tweaks

### Improve response speed time

[Source](https://github.com/open-webui/open-webui/discussions/7821#discussioncomment-11641870)

If responses from the LLM are slow, try switching off `"Retrieval Query Generation"`, `"Tags Generation"`, and `"Autocomplete Generation"` in the web UI. These configurations can be found by opening `Admin Panel` -> `Settings` -> `Interface`.

If using Docker Compose, you can set the environment variables:

- `OPENWEBUI_ENABLE_AUTOCOMPLETE_GENERATION=false`
- `OPENWEBUI_ENABLE_TAGS_GENERATION=false`
- `OPENWEBUI_ENABLE_RETRIEVAL_QUERY_GENERATION=false`

Restart both Ollama and Open-WebUI after making this change.

## Links

- [Open-webui documentation](https://docs.openwebui.com/getting-started/)
- [Install Nvidia container toolkit](https://gist.github.com/GurucharanSavanth/ee67321a63975e1c26e0765e2561ae9d#install-docker-and-nvidia-container-toolkit)
- [open-webui default setup](https://github.com/open-webui/open-webui#installation-with-default-configuration)
- [Installing open-webui with bundled ollama](https://github.com/open-webui/open-webui#installing-open-webui-with-bundled-ollama-support)
