<#
.SYNOPSIS
    Run the tools Docker container with optional volume mounts and commands.

.DESCRIPTION
    This script provides three modes of operation:
    1. Run container and drop into shell (no parameters)
    2. Run container with volume mount(s) and drop into shell
    3. Run container with optional volume mount(s) and execute a command

.PARAMETER Volumes
    One or more volume mounts in the format "host:container".
    Examples: "C:\Projects:/workspace", "${PWD}:/workspace"

.PARAMETER Command
    Command to execute inside the container. If not specified, drops into a shell.

.PARAMETER ImageTag
    Tag of the tools image to use. Default: "latest"

.PARAMETER WorkDir
    Working directory inside the container. Default: none (uses container default)

.EXAMPLE
    .\run.ps1
    Run container and drop into shell (Mode 1)

.EXAMPLE
    .\run.ps1 -Volumes "${PWD}:/workspace"
    Run container with current directory mounted (Mode 2)

.EXAMPLE
    .\run.ps1 -Volumes "C:\Projects:/workspace", "C:\Data:/data"
    Run container with multiple volume mounts (Mode 2)

.EXAMPLE
    .\run.ps1 -Command "terraform --version"
    Run container and execute a command (Mode 3)

.EXAMPLE
    .\run.ps1 -Volumes "${PWD}:/workspace" -Command "terraform init" -WorkDir "/workspace"
    Run container with volume mount, execute command in specific directory (Mode 3)

.EXAMPLE
    .\run.ps1 -Volumes "${PWD}:/workspace" -Command "pwsh -c 'Get-ChildItem'"
    Run container with complex command (Mode 3)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]]$Volumes,

    [Parameter(Mandatory=$false)]
    [string]$Command,

    [Parameter(Mandatory=$false)]
    [string]$ImageTag = "latest",

    [Parameter(Mandatory=$false)]
    [string]$WorkDir
)

# Check if Docker is available
if (-Not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not available in the system PATH."
    exit 1
}

# Check if the image exists
$imageName = "tools:$ImageTag"
$imageExists = docker images -q $imageName 2>$null
if (-Not $imageExists) {
    Write-Warning "Image '$imageName' not found locally."
    Write-Host "You may need to build it first. Run:" -ForegroundColor Yellow
    Write-Host "  .\build.ps1" -ForegroundColor Gray
    Write-Host ""
    $response = Read-Host "Do you want to continue anyway? Docker will try to pull the image (y/n)"
    if ($response -notmatch '^[Yy]') {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit 0
    }
}

# Build the Docker command
$dockerArgs = @(
    "run"
    "-it"
    "--rm"
)

# Add volume mounts if specified
if ($Volumes) {
    Write-Host "Volume mounts:" -ForegroundColor Cyan
    foreach ($volume in $Volumes) {
        Write-Host "  - $volume" -ForegroundColor Gray
        $dockerArgs += "-v"
        $dockerArgs += $volume
    }
}

# Add working directory if specified
if ($WorkDir) {
    Write-Host "Working directory: $WorkDir" -ForegroundColor Cyan
    $dockerArgs += "-w"
    $dockerArgs += $WorkDir
}

# Add the image name
$imageName = "tools:$ImageTag"
$dockerArgs += $imageName

# Add command if specified
if ($Command) {
    Write-Host "Executing command: $Command" -ForegroundColor Cyan
    # Split the command to handle arguments properly
    $dockerArgs += "/bin/sh"
    $dockerArgs += "-c"
    $dockerArgs += $Command
} else {
    Write-Host "Starting interactive shell..." -ForegroundColor Cyan
}

# Display the full command being executed
Write-Host "`nDocker command:" -ForegroundColor Yellow
Write-Host "docker $($dockerArgs -join ' ')" -ForegroundColor Gray
Write-Host ""

# Execute the Docker command
try {
    & docker $dockerArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Docker command failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
} catch {
    Write-Error "Failed to run Docker container: $_"
    exit 1
}
