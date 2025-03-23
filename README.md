# Docker Templates <!-- omit in toc -->

<!-- Repo image -->
<p align="center">
  <a href="https://github.com/redjax/docker_templates">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="src/img/repo-readme-header.png">
      <img src="src/img/repo-readme-header.png" height="100">
    </picture>
  </a>
</p>

<!-- Git Badges -->
<p align="center">
  <a href="https://github.com/redjax/docker_templates">
    <img alt="Created At" src="https://img.shields.io/github/created-at/redjax/docker_templates">
  </a>
  <a href="https://github.com/redjax/docker_templates/commit">
    <img alt="Last Commit" src="https://img.shields.io/github/last-commit/redjax/docker_templates">
  </a>
  <a href="https://github.com/redjax/docker_templates/commit">
    <img alt="Commits this year" src="https://img.shields.io/github/commit-activity/y/redjax/docker_templates">
  </a>
  <a href="https://github.com/redjax/docker_templates">
    <img alt="Repo size" src="https://img.shields.io/github/repo-size/redjax/docker_templates">
  </a>
  <!-- ![GitHub Latest Release](https://img.shields.io/github/release-date/redjax/docker_templates) -->
  <!-- ![GitHub commits since latest release](https://img.shields.io/github/commits-since/redjax/docker_templates/latest) -->
  <!-- ![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/redjax/docker_templates/tests.yml) -->
</p>

<p align="center">
  Templates: 129
  <span>(counted with <a href="./scripts/count_templates.py">count_templates.py</a>)</span>
</p>

---

Templates for Docker/Compose containers. Some are completely custom, but most are an example `compose.yml`/`docker-compose.yml` file and example `.env` file.

Check the [template categories section](#template-categories) for a list of template types.

## Table of Contents  <!-- omit in toc -->

- [Instructions](#instructions)
  - [Method 1: Clone the whole repository](#method-1-clone-the-whole-repository)
    - [Use a symlink](#use-a-symlink)
  - [Method 2: Copy/paste](#method-2-copypaste)
  - [Method 3: Sparse clone](#method-3-sparse-clone)
    - [How to do a sparse checkout](#how-to-do-a-sparse-checkout)
- [Template Categories](#template-categories)

## Instructions

### Method 1: Clone the whole repository

- Clone this whole repository: `git clone git@github.com:redjax/docker_templates`.
- `cd` to the directory of the container(s) you want to run
- Read the instructions in the `README.md`, if there is one
- Copy `.env.example` -> `.env`, if it exists
  - Edit the `.env` file to your liking
- Run `docker compose up -d` (or another command, if listed in the `README.md`)

#### Use a symlink

If you want to create a link to a template, i.e. if you are running a [Palworld server](./templates/games/docker_palworld_server/) and want a link to the template directory in your `$HOME`, you can use `ln -s` on Linux:

```bash
ln -s /path/to/docker_templates/templates/games/docker_palworld_server /path/to/link
```

With `ln -s`, avoid using variables like `$HOME` or `~`. These symbolic links are brittle, they work best with absolute paths and will break if you move the source path.

### Method 2: Copy/paste

- Navigate to the container(s) you want
- Copy/paste the files, or create the files in your desired path and copy the contents of each file from this repository
- Follow any instructions listed for the container(s)

### Method 3: Sparse clone

You can use a [sparse checkout](https://git-scm.com/docs/git-sparse-checkout) to clone parts of this repository. This retains the git structure, while allowing you to "scope" your clone to a specific pathh in the repository.

For example, if you are running a [Minecraft server](./templates/games/docker_minecraft_server/), any time you switch branches to a branch that does not have the code for the currently running server(s), you will corrupt the server if the container is currently running. This leads to either data corruption, or repeatedly cloning the entire repository whenever you want to modify parts of the repository tree.

Instead, you can do a `git sparse-checkout` and select only certain path(s) to clone. You can still switch branches, modify code, push/pull changes, etc, but only the path you have checked out will be affected.

#### How to do a sparse checkout

For this example, we will checkout only the [Minecraft BigChadGuys server](./templates/games/docker_minecraft_server/servers/production/mc-bigchadguys/). You can change the steps below to fit your needs, i.e. selecting a different file path than the Docker Minecraft BigChadGuys server, or a different branch than `main`.

1. Clone the repository with minimal history using `git clone --no-checkout git@github.com/redjax/docker_templates.git`
   1. You can choose a different directory name than `docker_templates` by adding a filepath onto the end. For example, to clone into a directory named `docker_minecraft_bcg`:
      1. `git clone --no-checkout git@github.com/redjax/docker_templates.git docker_minecraft_bcg`
   2. `cd` into your newly cloned path
2. Enable sparse checkout with `git sparse-checkout set templates/games/docker_mineceraft_server/servers/production/mc-bigchadguys <optional other paths>`
   1. You can add multiple paths after `set` to checkout more than 1 path. Add them where you see `<optional other paths>`
3. Checkout the repository
   1. `git checkout <branch-name>`

After doing a sparse checkout, you can work on this single path of the repository the way you would if you had cloned the whole repository. You can create/switch branches, do `git push`/`git pull` operations, etc.

## Template Categories

All templates are stored in the [`./templates`](./templates) path in one of the categories below.

| Template Type                                            | Description                                                                      |
| -------------------------------------------------------- | -------------------------------------------------------------------------------- |
| [automation](./templates/automation)                     | Automations like CI/CD, web agents, no/low-code, etc.                            |
| [backup](./templates/backup)                             | Containers for setting up backup infrastructure.                                 |
| [bookmarking](./templates/bookmarking)                   | Containers for cataloguing/sharing bookmarks.                                    |
| [bots](./templates/bots)                                 | Containers for bot infrastructure, i.e. Discord and Telegram bots.               |
| [code forges](./templates/code)                          | Code forges like Gitea for a self-hosted, Github-like experience.                |
| [database](./templates/database)                         | Containers for database servers, like PostgreSQL and MariaDB.                    |
| [documents](./templates/documents)                       | Document management, OCR, & more.                                                |
| [games](./templates/games)                               | Dockerized game servers, like Palworld, Valheim, and Satisfactory.               |
| [llm](./templates/llm)                                   | Containers for LLMs like ollama.                                                 |
| [media](./templates/media)                               | Containers for media management/streaming.                                       |
| [messaging](./templates/messaging)                       | Messaging services & event queues like MQTT, RabbitMQ, etc.                      |
| [misc](./templates/misc)                                 | Miscellaneous templates for specific environments.                               |
| [monitoring & alerting](./templates/monitoring_alerting) | Monitoring & alerting infrastructure.                                            |
| [networking](./templates/networking)                     | Containers for setting up networking infrastructure like reverse proxies & VPNs. |
| [rss](./templates/rss)                                   | Containers for managing & reading RSS feeds.                                     |
| [storage](./templates/storage)                           | Storage containers like SeaFile and Minio S3 storage.                            |
| [unsorted](./templates/unsorted)                         | Containers that have not been sorted or do not fit neatly into another category. |
| [web scraping](./templates/web_scraping/)                | Containers for facilitating web scraping, like Selenium.                         |
