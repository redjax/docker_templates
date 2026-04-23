[CmdletBinding()]
Param(
    [string]$Tag = "mise-tools:alpine",
    [string]$Dockerfile = ".\Dockerfile.alpine",
    [string]$GitHubTokenFile = ".\github_token.txt"
)

if ( -Not ( Get-Command docker -ErrorAction SilentlyContinue ) ) {
    Write-Error "Docker is not installed or not available in the system PATH."
    exit 1
}

if ( -Not ( Test-Path $Dockerfile ) ) {
    Write-Error "Dockerfile not found at path: $Dockerfile"
    exit 1
}

$Dockerfile = (Resolve-Path $Dockerfile).Path

$useGitHubToken = $false
if ( Test-Path $GitHubTokenFile ) {
    $GitHubTokenFile = (Resolve-Path $GitHubTokenFile).Path
    $useGitHubToken = $true
    Write-Host "Using GitHub token from: $GitHubTokenFile" -ForegroundColor Green
} else {
    Write-Host "No GitHub token file found at: $GitHubTokenFile" -ForegroundColor Yellow
    Write-Host "Building without GitHub token (may hit rate limits)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Building Alpine-based mise container '$Tag'" -ForegroundColor Cyan
Write-Host ""

try {
    if ( $useGitHubToken ) {
        docker build --secret "id=github_token,src=$GitHubTokenFile" -t $Tag --file $Dockerfile .
    } else {
        docker build -t $Tag --file $Dockerfile .
    }
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
Write-Host "Execute the container with:" -ForegroundColor Cyan
Write-Host "  docker run -it --rm $Tag" -ForegroundColor Yellow
Write-Host ""
