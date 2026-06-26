# Renovate

[Renovate](https://www.mend.io/renovate/) is a tool for scanning repositories across git forges and automating dependency bumping. This template runs the [Renovate CLI](https://github.com/renovatebot/renovate).

## Setup

- Copy the [example `.env` file](./.example.env) to `.env` and edit it. At minimum you need to provide:
  - `RENOVATE_TOKEN`: The API token/PAT for the target platform with read/write permissions for Renovate to run on your repos.
  - `RENOVATE_REPOSITORIES`: Comma-separated list of repos, i.e. `username/repo1,username/repo2,username/repo3`

The Renovate container supports [multiple code forges](https://docs.renovatebot.com/modules/platform/), but each Docker instance can only target a single platform. If you want to target multiple forges, i.e. Github and Gitlab, you need to run 2 instances of this container.

### Github Setup

On Github, you must create a fine-grained token to grant Renovate permissions to operate on your repositories. You should create 2 tokens, a "read only" version with minimal read access, and a "read/write" token that Renovate will use to manage issues, pull requests, etc.

Create tokens for the following env vars:

- `RENOVATE_GITHUB_COM_TOKEN`: Read-only access
  - For optimal security, grant access to specific repositories, only the ones Renovate will interact with.
  - `Contents`: Read-only
  - `Metadata`: Read-only

- `RENOVATE_TOKEN`: Read/write access
  - `Contents`: Read and write
  - `Pull requests`: Read and write
  - `Metadata`: Read-only
  - `Commit statuses`: Read and write
  - `Workflows`: Read and write, if you want Renovate to update files under `.github/workflows/` and create PRs that touch workflow files

## Configuration

You will need to [configure your Renovate server](https://docs.renovatebot.com/config-overview/) according to your individual needs. Do this by copying the [example `.config.js`](./config/example.config.js) to `config/config.js` and edit it.
