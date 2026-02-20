# OpenBao

[OpenBao](https://openbao.org) is an open-source fork of Hashicorp Vault.

## Setup Steps

- Copy the [example `.env` file](./.example.env) to `.env` and set any env var overrides.
- Run `docker compose up -d`
- Initialize OpenBao operator:

  ```shell
  docker compose exec -it openbao bao operator init
  ```

  - You will see 5 unseal keys and a root token.
  - **IMPORTANT**: Save these keys in a password manager! If you lose access to them, you will be locked out of your vault.

After initializing OpenBao, you can use the following steps to unseal the vault.

> [!NOTE]
> You will need to do this each time you restart the container unless you enable auto-unseal.

- Unseal the vault with:

  ```shell
  docker compose exec -it openbao bao operator unseal
  ```

  - You will be prompted for a key 3 times; enter a different key from the original 5 at each prompt.
- Log into the vault:

  ```shell
  docker compose exec -it openbao bao login
  ```

Now that the vault is unsealed, you should be able to access the webUI at `http(s)://ip-or-fqdn:8200`.

You can store secrets from the CLI with:

```shell
docker compose exec -it openbao bao kv put secret/hello value="Hello World"
```

## Links

- [OpenBao home](https://openbao.org)
- [OpenBao docs](https://openbao.org/docs/what-is-openbao/)
