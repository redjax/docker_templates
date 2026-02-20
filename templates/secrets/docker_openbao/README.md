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

## Key/Token Rotation

> [!NOTE]
> You should rotate your keys every 3-6 months, at minimum. See the [rotation checklist]() for instructions

### Rotate unseal keys

Run the following command to generate a new set of unseal keys, overwriting the old ones.

```shell
docker compose exec -it openbao bao operator rekey
```

### Rotate root token

Login as root:

```shell
docker compose exec -it openbao bao login
```

Generate a neww token (`-orphan` ensures it's independent of the current root token):

```shell
docker exec -it openbao bao token create -policy=admin -orphan
```

Revoke the old token:

```shell
docker exec -it openbao bao token revoke <old-root-token>
```

### Rotation Checklist

- Make sure OpenBao is running and unsealed

  ```shell
  docker compose ps
  docker compose exec -it openbao bao status
  ```

  - You should see `Sealed: false`
- Rotate the root token
  
  ```shell
  docker compose exec -it openbao bao login
  ```

  - Create a new root token
    
    ```shell
    docker compose exec -it openbao bao token create -policy=admin -orphan
    ```

  - Revoke old root token

    ```shell
    docker exec -it openbao bao token revoke <old-root-token>
    ```

- Rotate unseal keys ("rekey")

  ```shell
  docker compose exec -it openbao bao operator rekey
  ```

  - After unsealing with 3 of the 5 existing keys, OpenBao will print the new keys.
  - Save these in a password manager.

- Test unsealing with the new keys
  - Re-seal the vault

  ```shell
  docker compose exec -it openbao bao operator seal
  ```

  - Unseal using the new keys:

  ```shell
  docker compose exec -it openbao bao operator unseal
  ```

  - Enter 3 of the 5 new unseal keys
  - Check that the vault is `Sealed: false`

  ```shell
  docker compose exec -it openbao bao status
  ```

- Make sure the new root token has the expected policies:

```shell
docker compose exec -it openbao bao token lookup <new-token>
```

## Links

- [OpenBao home](https://openbao.org)
- [OpenBao docs](https://openbao.org/docs/what-is-openbao/)
