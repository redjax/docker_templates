# Renovate

[Renovate](https://www.mend.io/renovate/) is a tool for scanning repositories across git forges and automating dependency bumping. This template runs the [Renovate CLI](https://github.com/renovatebot/renovate).

- [Renovate docs](https://docs.renovatebot.com)

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

## Repository-local renovate.json

Individual repositories can override Renovate's default config by putting a `renovate.json` file at the root of the repository.

### Default/minimal

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "dependencyDashboard": true
}
```

### Python

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "dependencyDashboard": true,
  "enabledManagers": ["pep621", "pip_requirements", "pip-compile", "poetry", "pre-commit"],
  "packageRules": [
    {
      "matchManagers": ["pep621"],
      "groupName": "Python dependencies"
    }
  ]
}
```

### Go

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "dependencyDashboard": true,
  "enabledManagers": ["gomod"],
  "packageRules": [
    {
      "matchManagers": ["gomod"],
      "groupName": "Go dependencies"
    }
  ]
}
```

### Github Actions

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "dependencyDashboard": true,
  "enabledManagers": ["github-actions"],
  "packageRules": [
    {
      "matchManagers": ["github-actions"],
      "groupName": "GitHub Actions"
    }
  ]
}
```

### Docker

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "dependencyDashboard": true,
  "enabledManagers": ["dockerfile", "docker-compose"],
  "packageRules": [
    {
      "matchManagers": ["dockerfile", "docker-compose"],
      "groupName": "Docker dependencies"
    }
  ]
}
```

### Terraform

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "dependencyDashboard": true,
  "enabledManagers": ["terraform", "terraform-version", "terragrunt", "terragrunt-version", "tflint-plugin"],
  "packageRules": [
    {
      "matchManagers": ["terraform", "terragrunt"],
      "groupName": "Terraform"
    }
  ]
}
```

### Node

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "dependencyDashboard": true,
  "enabledManagers": ["npm", "nvm", "mise"],
  "packageRules": [
    {
      "matchManagers": ["npm"],
      "groupName": "Node dependencies"
    }
  ]
}
```
