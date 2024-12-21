# ollama_webui

Ollama LLM with [OpenWebUI](https://github.com/open-webui/open-webui) container

## Description

Runs a chat webUI with embedded Ollama. The `open-webui` container and `ollama` are both meant to run completely offline. Run your own private chatbot and stop training corporations' models for free.

## Usage

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

This directory includes a [`compose.yml`](./compose.yml) file. Create a `.env` file by copying `.env.example` -> `.env`, then edit it, editing any runtime variables you wish to change.

Once your `.env` file is setup, run `docker compose up -d` and browse to `http://your-servername-or-ip:3000` (if you changed the `OPENWEBUI_PORT` env variable, use that port instead).

If you have a Nvidia GPU and have installed the [Nvidia container toolkit](https://gist.github.com/GurucharanSavanth/ee67321a63975e1c26e0765e2561ae9d#install-docker-and-nvidia-container-toolkit), you can run `ollama` with GPU support by running:

```shell
docker compose -f nvidia.compose.yml up -d
```

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

## Links

- [Open-webui documentation](https://docs.openwebui.com/getting-started/)
- [Install Nvidia container toolkit](https://gist.github.com/GurucharanSavanth/ee67321a63975e1c26e0765e2561ae9d#install-docker-and-nvidia-container-toolkit)
- [open-webui default setup](https://github.com/open-webui/open-webui#installation-with-default-configuration)
- [Installing open-webui with bundled ollama](https://github.com/open-webui/open-webui#installing-open-webui-with-bundled-ollama-support)
