[CmdletBinding()]
Param(
    [string]$Tag = "aqua-tools:latest",
    [string]$Dockerfile = ".\Dockerfile",
    [string]$GitHubTokenFile = ".\github_token.txt",
    [string]$PythonVersion = "3.13",
    [string]$AquaInstallerVersion = "v4.0.4",
    [string]$AquaVersion = "v2.55.3"
)

$ScriptDir = $PSScriptRoot
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")

if ( -Not ( Get-Command docker -ErrorAction SilentlyContinue ) ) {
    Write-Error "Docker is not installed or not available in the system PATH."
    exit 1
}

if ( -Not ( Test-Path $Dockerfile ) ) {
    Write-Error "Dockerfile not found at path: $Dockerfile"
    exit 1
}

$Dockerfile = (Resolve-Path $Dockerfile).Path
$GitHubTokenFile = Join-Path $ScriptDir "github_token.txt"

# Build arguments
$buildArgs = @(
    "--build-arg", "PYTHON_VERSION=$PythonVersion",
    "--build-arg", "AQUA_INSTALLER_VERSION=$AquaInstallerVersion",
    "--build-arg", "AQUA_VERSION=$AquaVersion"
)

$secretArgs = @()
if ( Test-Path $GitHubTokenFile ) {
    $GitHubTokenFile = (Resolve-Path $GitHubTokenFile).Path
    $secretArgs = @("--secret", "id=github_token,src=$GitHubTokenFile")
    Write-Host "Using GitHub token from: $GitHubTokenFile" -ForegroundColor Green
} else {
    Write-Host "No GitHub token file found at: $GitHubTokenFile" -ForegroundColor Yellow
    Write-Host "Building without GitHub token (may hit rate limits)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Building Aqua container '$Tag'" -ForegroundColor Cyan
Write-Host "  Base: python:$PythonVersion-slim-bookworm" -ForegroundColor Cyan
Write-Host "  Aqua Installer: $AquaInstallerVersion" -ForegroundColor Cyan
Write-Host "  Aqua CLI: $AquaVersion" -ForegroundColor Cyan
Write-Host ""

$dockerArgs = @("build") + $secretArgs + $buildArgs + @("-t", $Tag, "--file", $Dockerfile, $RepoRoot)

try {
    & docker @dockerArgs
} catch {
    Write-Error "Failed to build the Docker image: $_"
    exit 1
}

if ( $LASTEXITCODE -ne 0 ) {
    Write-Error "Docker build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Run the container with:" -ForegroundColor Cyan
Write-Host "  docker run -it --rm $Tag" -ForegroundColor Yellow
Write-Host ""
Write-Host "Or with a mounted workspace:" -ForegroundColor Cyan
Write-Host "  docker run -it --rm -v `${PWD}:/workspace $Tag" -ForegroundColor Yellow
Write-Host ""
