# Shared

Configurations & scripts shared by multiple [Dockerfiles](../).

## Using in a Dockerfile build

Because the `shared/` directory is a subdirectory of `dockerfiles/`, the build context needs to be the repository root.

In your scripts, `cd` to the repository's root before calling a `docker build` command, i.e.:

```shell
#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "${REPO_ROOT}"

...

```

Then in the Dockerfile, use relative paths from the root, i.e.

```dockerfile
FROM ...

...

COPY shared/config/nvim /root/.config/nvim
```
