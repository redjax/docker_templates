# Soft Serve

[Soft-Serve](https://github.com/charmbracelet/soft-serve) is a simple Git server written in go. Spin up a container or run the binary and immediately connect via SSH to start using.

## Setup

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
