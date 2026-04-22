[CmdletBinding()]
Param(
    [string]$Tag = "tools:latest",
    [string]$Dockerfile = "Dockerfile",
    [string]$PythonVersion = "3.13",
    [string]$UVVersion = "0.9.18",
    [string]$GitleaksVersion = "8.18.1",
    [string]$OSVVersion = "1.5.0",
    [string]$TerraformVersion = "1.9.8",
    [string]$TerraformLSVersion = "0.34.3",
    [string]$TFSecVersion = "1.28.10",
    [string]$TFLintVersion = "0.53.0",
    [string]$GoVersion = "1.25.5"
)

## Resolve paths relative to script location
$ScriptDir = $PSScriptRoot
if (-not [System.IO.Path]::IsPathRooted($Dockerfile)) {
    $Dockerfile = Join-Path $ScriptDir $Dockerfile
}
$Dockerfile = (Resolve-Path $Dockerfile).Path

if ( -Not ( Get-Command docker -ErrorAction SilentlyContinue ) ) {
    Write-Error "Docker is not installed or not available in the system PATH."
    exit 1
}

if ( -Not ( Test-Path $Dockerfile ) ) {
    Write-Error "Dockerfile not found at path: $Dockerfile"
    exit 1
}

Write-Host ""
Write-Host "Building container '$Tag' with Dockerfile at path '$Dockerfile'" -ForegroundColor Cyan
Write-Host "Build context: $ScriptDir" -ForegroundColor Cyan
Write-Host ""

try {
    docker build `
        -t $Tag `
        --file $Dockerfile `
        --build-arg UV_VER="$UVVersion" `
        --build-arg PYTHON_VER="$PythonVersion" `
        --build-arg GITLEAKS_VER="$GitleaksVersion" `
        --build-arg OSV_VER="$OSVVersion" `
        --build-arg TERRAFORM_VER="$TerraformVersion" `
        --build-arg TERRAFORM_LS_VER="$TerraformLSVersion" `
        --build-arg TFSEC_VER="$TFSecVersion" `
        --build-arg TFLINT_VER="$TFLintVersion" `
        --build-arg GO_VER="$GoVersion" `
        $ScriptDir
} catch {
    Write-Error "Failed to build the Docker image: $_"
    exit 1
}

if ( $LASTEXITCODE -ne 0 ) {
    Write-Error "Docker build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Build completed successfully for image: $Tag" -ForegroundColor Green
Write-Host "Execute the container with:"
Write-Host "  docker run -it --rm $Tag"
Write-Host "Or, if you want to mount the current directory in the container:"
Write-Host "  docker run -it --rm -v ${PWD}:/workspace $Tag"
Write-Host ""
