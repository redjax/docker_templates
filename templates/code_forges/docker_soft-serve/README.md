# Soft Serve

[Soft-Serve](https://github.com/charmbracelet/soft-serve) is a simple Git server written in go. Spin up a container or run the binary and immediately connect via SSH to start using.

## Setup

- Copy the [example .env file](./.env.example) to `.env`.
  - Optionally edit any values you want to change.
- Copy the [example `soft-serve.yml` server config file](./config/examples/soft-serve.yml) to `./config/soft-serve.yml`.
  - Optionally, edit any of the server configuration in this file.
- Do the [SSH setup](#ssh-setup), or if you already have a key, paste the contents of the public key in the `.env` file's `SOFTSERVE_INITIAL_ADMIN_KEYS=` variable.
- Bring the container up with `docker compose up -d`.
- Connect to it with `ssh -i /path/to/id_ed25519 localhost -p 23231` (or whatever private key you created).

### SSH Setup

Generate an SSH key to use with soft-serve:

```shell
ssh-keygen -t ed25519 -N "" -C "" -f ~/.ssh/id_ed25519
```

Edit your `~/.ssh/config` to add `soft` as an SSH target:

```plaintext
Host soft
  HostName localhost
  Port 23231
  IdentityFile ~/.ssh/soft-serve_id_ed25519
  IdentitiesOnly yes
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```

Now you can connect to `soft-serve` with `ssh soft [COMMANDS] [OPTIONS]`. For example, create a new repository with:

```shell
ssh soft repo create
```

## Usage

### Cheat Sheet

| Command                                                                                            | Description                                           |
| -------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| `ssh <your softserve ip/port/hostname>`                                                            | Connect to soft-serve server.                         |
| `ssh <your softserve ip/port/hostname> repo create <repository-name>`                              | Create a new repository in soft-serve.                |
| `ssh <your softserve ip/port/hostname> repo tree <repository-name>`                                | Print the directory tree for a repository.            |
| `ssh <your softserve ip/port/hostname> repo blob <repository-name> path/in/repo/to/file.ext`       | Print the contents of a specific file.                |
| `ssh <your softserve ip/port/hostname> repo blob <repository-name> path/in/repo/to/file.ext -c -l` | Print a file with syntax highlighting & line numbers. |

[If you have installed the `soft` CLI](https://github.com/charmbracelet/soft-serve#installation), you can also run most of these commands locally against local git repositories. For example, to browse a local repository:

```shell
soft browse /path/to/git/repo
```
