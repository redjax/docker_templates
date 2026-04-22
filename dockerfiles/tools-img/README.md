# Tools Container

A Docker container with some tools pre-installed.

## Tools

- Azure CLI
- Powershell (`pwsh`)
- Terraform
  - Terraform language server
  - TFSec
  - TFLint
- Gitleaks
- osv-scanner
- Python
- Go
- Uv
- Neovim (with my custom no-plugins configuration)
- Zellij

## Build

You can use the [included `build.ps1` script](./build.ps1), or run the following command to build the container:

```shell
docker build `
    -t tools:latest `
    --file .\Dockerfile `
    --build-arg UV_VER="$UVVersion" `
    --build-arg PYTHON_VER="$PythonVersion" `
    --build-arg GITLEAKS_VER="$GitleaksVersion" `
    --build-arg OSV_VER="$OSVVersion" `
    --build-arg TERRAFORM_VER="$TerraformVersion" `
    --build-arg TERRAFORM_LS_VER="$TerraformLSVersion" `
    --build-arg TFSEC_VER="$TFSecVersion" `
    --build-arg TFLINT_VER="$TFLintVersion" `
    --build-arg GO_VER="$GoVersion"
```

The `--build-arg` flags are optional; if you do not pass them, the Dockerfile will use whatever predefined `ARG` lines there are. You can also override individual versions, providing only a few specific versions.

## Run

After [building the image](#build), you can run it directly with Docker or use the included [`run.ps1` script](#using-the-runps1-script) for easier management.

### Using Docker directly

Run the container and drop into a shell:

```shell
docker run -it --rm tools:latest
```

Mount the current directory in the container:

```shell
docker run -it --rm -v ${PWD}:/workspace tools:latest
```

You can mount any volumes you want with `-v`, but you should use absolute paths, i.e. `C:\Path\to\Mount`, instead of relative paths like `..\..\Some\Path`.

### Using the run.ps1 script

The included [`run.ps1` script](./run.ps1) provides a convenient wrapper for running the container with three modes of operation:

- Interactive shell (no parameters)

  ```powershell
  .\run.ps1
  ```

- Interactive shell with volume mounts
  - Mount the current directory:

    ```powershell
    .\run.ps1 -Volumes "${PWD}:/workspace"
    ```

  - Mount multiple volumes

    ```powershell
    .\run.ps1 -Volumes "C:\Projects:/workspace", "C:\Data:/data"
    ```

  - Mount with absolute path

    ```powershell
    .\run.ps1 -Volumes "C:\Environments:/workspace"
    ```

- Execute a command
  - Run a command without mounting volumes

    ```powershell
    .\run.ps1 -Command "terraform --version"
    ```

  - Run a command with a volume mount

    ```powershell
    .\run.ps1 -Volumes "${PWD}:/workspace" -Command "terraform init"
    ```

  - Run a command in a specific working directory

    ```powershell
    .\run.ps1 -Volumes "${PWD}:/workspace" -Command "terraform validate" -WorkDir "/workspace"
    ```

  - Execute complex commands

    ```powershell
    .\run.ps1 -Volumes "${PWD}:/workspace" -Command "pwsh -c 'Get-ChildItem; terraform --version'"
    ```

- Additional Parameters
  - **`-ImageTag`**: Specify a different image tag (default: `latest`)
  
    ```powershell
    .\run.ps1 -ImageTag "v1.0.0"
    ```

  - **`-WorkDir`**: Set the working directory inside the container

    ```powershell
    .\run.ps1 -Volumes "${PWD}:/workspace" -WorkDir "/workspace"
    ```

- View detailed help and examples:

  ```powershell
  Get-Help .\run.ps1 -Full
  ```
