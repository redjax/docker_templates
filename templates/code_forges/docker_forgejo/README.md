# Forgejo

[Forgejo](https://forgejo.org) code for (alternative to Github).

## Setup

Run the [initial setup script](./scripts/initial_setup.sh) to create the `data/forgejo` directory, set the correct permissions, and copy example environment files in the [`env_files/` directory](./env_files/).

Start the stack, navigate to your URL, and complete the setup. Make sure to create an admin account (at the bottom of the page). The container will restart, at which point you should bring it down, edit your env file (default is `env_files/forgejo/default.env`) and set `FORGEJO__security__INSTALL_LOCK=true`, then bring the stack back up.

## Links

- [Forgejo home](https://forgejo.org)
- [Forgejo docs](https://forgejo.org/docs/latest/)
- [Forgejo containers](https://codeberg.org/forgejo/-/packages/container/forgejo/versions)
