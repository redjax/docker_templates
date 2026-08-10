# Github Runner

A self-hosted Github Actions runner

## Description

[Github: myoung34/docker-github-actions-runner](https://github.com/myoung34/docker-github-actions-runner)

## Instructions

### Github Repository Setup

- Enable Actions in your Github repository (Settings -> Actions)
- Create a PAT
    - Navigate to your Settings > Developer Settings > Personal Access Tokens
    - Click Generate new token and select an expiration date
- Give the PAT the following permissions, according to your needs:
    - `Events`: `read-only`

### Local Docker setup

- Copy [`.env.example`](./.env.example) -> `.env`
    - Set variables including the target repo URL and a Github Action PAT
- Run `docker compose up -d`
