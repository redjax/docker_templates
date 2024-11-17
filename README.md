# Docker Templates

Templates for Docker/Compose containers. Some are completely custom, but most are an example `compose.yml`/`docker-compose.yml` file and example `.env` file.

Check the [template categories section](#template-categories) for a list of template types.

## Instructions

### Method 1: Clone the whole repository

- Clone this whole repository: `git clone git@github.com:redjax/docker_templates`.
- `cd` to the directory of the container(s) you want to run
- Read the instructions in the `README.md`, if there is one
- Copy `.env.example` -> `.env`, if it exists
  - Edit the `.env` file to your liking
- Run `docker compose up -d` (or another command, if listed in the `README.md`)

### Method 2: Copy/paste

- Navigate to the container(s) you want
- Copy/paste the files, or create the files in your desired path and copy the contents of each file from this repository
- Follow any instructions listed for the container(s)

## Template Categories

All templates are stored in the [`./templates`](./templates) path in one of the categories below.

| Template Type | Description |
| ------------------ | ----------- |
| [automation](./templates/automation) | Automations like CI/CD, web agents, no/low-code, etc. |
| [backup](./templates/backup) | Containers for setting up backup infrastructure. |
| [bookmarking](./templates/bookmarking) | Containers for cataloguing/sharing bookmarks. |
| [bots](./templates/bots) | Containers for bot infrastructure, i.e. Discord and Telegram bots. |
| [code forges](./templates/code) | Code forges like Gitea for a self-hosted, Github-like experience. |
| [database](./templates/database) | Containers for database servers, like PostgreSQL and MariaDB. |
| [documents](./templates/documents) | Document management, OCR, & more. |
| [games](./templates/games) | Dockerized game servers, like Palworld, Valheim, and Satisfactory. |
| [media](./templates/media) | Containers for media management/streaming. |
| [messaging](./templates/messaging) | Messaging services & event queues like MQTT, RabbitMQ, etc. |
| [misc](./templates/misc) | Miscellaneous templates for specific environments. |
| [monitoring & alerting](./templates/monitoring_alerting) | Monitoring & alerting infrastructure. |
| [networking](./templates/networking) | Containers for setting up networking infrastructure like reverse proxies & VPNs. |
| [rss](./templates/rss) | Containers for managing & reading RSS feeds. |
| [storage](./templates/storage) | Storage containers like SeaFile and Minio S3 storage. |
| [unsorted](./templates/unsorted) | Containers that have not been sorted or do not fit neatly into another category. |
| [web scraping](./templates/web_scraping/) | Containers for facilitating web scraping, like Selenium. |
