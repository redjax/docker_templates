# Gickup

Git repository mirroring & backup tool.

## Description

[Gickup](https://github.com/cooperspencer/gickup/tree/main) is a git repository backup tool. It supports scheduling & incremental backups, as well as multiple remote sources and destination.

## Setup

- Copy [`.env.example`](./.env.example) -> `.env`
  - Read over the `.env` file, think about your use case, and update any environment variables as needed.
  - If you want to persist data in a directory on the host, modify the `GICKUP_BACKUP_DIR` and/or the `GICKUP_LOGS_DIR`.
- Determine if you will be using [SSH keys](#ssh-key), [Personal Access Tokens (PATs)](#personal-access-token-pat), or some other form of authentication
  - Review the documentation for [your specific remote](https://cooperspencer.github.io/gickup-documentation/configuration/source_docu/intro) to determine which type(s) of access to use.
  - For example, when [backing up Github repositories](https://cooperspencer.github.io/gickup-documentation/configuration/source_docu/github), you can use an SSH key for authentication, but must provide a PAT for authorization to save things like wikis, issues, etc.
  - Place any secrets you create in the [`secrets/`](./secrets/) path and update environment variable(s) in the [`.env` file](./.env.example).
- Copy the [default Gickup configuration](./config/default.yml) and modify it to your needs.
  - Reference the [example config file](./config/example.yml), or check [the most recent example in the Gickup repository](https://github.com/cooperspencer/gickup/blob/main/conf.example.yml).
  - Options are highly specific to the exact type of synchronization

## SSH key

**NOTE: Wherever this document mentions 'adding' or 'uploading' your SSH key to a remote, this means the 'public' SSH key, i.e. `id_rsa.pub`. Never upload your private key!**

SSH keys are the most secure way to interact with your git remotes. There are some operations with Github or Gitlab, like backing up wikis, issues, and projects, that require additional authorization granted by a [Personal Access Token (PAT)](#personal-access-token-pat).

SSH can be used to facilitate *authentication*, but may not provide enough *authorization* for your backup. If you need to backup more than just the code in your repository (i.e. your source code, commits, and branches), you will likely need to use a PAT.

If you do not already have SSH authentication configured for your remote, create an SSH key with one of the commands below. After creating the key, you must [upload it to your remote](#add-ssh-key-to-git-remote).

### Create an SSH key

```bash
## Example: create an SSH key for Github
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_id_rsa -N ""
```

### Add SSH key to git remote

- [Instructions for Github](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
- [Instructions for Gitlab](https://docs.gitlab.com/ee/user/ssh.html#add-an-ssh-key-to-your-gitlab-account)
- [Instructions for Gitea](https://easycode.page/gitea-setup-ssh-and-repository/) (Gitea's official documentation does not have a page for this process)
- [Instructions for Bitbucket](https://support.atlassian.com/bitbucket-cloud/docs/set-up-personal-ssh-keys-on-windows/#Provide-Bitbucket-Cloud-with-your-public-key)

If you do not see your preferred remote, you can do a web search for "add SSH key to {git remote you use}" to see instructions specific to that remote host.

### Tell Gickup to use SSH key

...

## Personal Access Token (PAT)

Some remotes, like Github and Gitlab, allow for creation of "Personal Access Tokens (PATs)." These tokens provide granular permission scoping, and allow Gickup to perform additional actions like backing up wikis and issues for your repositories. Please check the documentation below for your preferred remote for instructions on creating PATs:

- [Github docs: Managing your personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [Gitlab docs: Personal access tokens](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html)
- [Gitea docs: generating and listing API tokens](https://docs.gitea.com/development/api-usage#generating-and-listing-api-tokens)
- [Bitbucket docs: Personal access tokens](https://confluence.atlassian.com/bitbucketserver076/personal-access-tokens-1026534797.html)

### Tell Gickup to use PAT

...

## Links

- [Gickup home](https://cooperspencer.github.io/gickup-documentation/)
- [Gickup Github](https://github.com/cooperspencer/gickup/tree/main)
  - [Gickup releases](https://github.com/cooperspencer/gickup/releases)
  - [Gickup example conf.yml](https://github.com/cooperspencer/gickup/blob/main/conf.example.yml)
  - [Gickup example compose.yml](https://github.com/cooperspencer/gickup/blob/main/docker-compose.yml)
- [Gickup Docker](https://hub.docker.com/r/buddyspencer/gickup)
