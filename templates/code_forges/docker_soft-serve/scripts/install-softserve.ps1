## Variables
$repo = "charmbracelet/soft-serve"
$apiUrl = "https://api.github.com/repos/$repo/releases/latest"
$installDir = "$Env:LocalAppData\Programs\SoftServe"
$exeName = "soft.exe"
$tempDir = Join-Path $Env:TEMP ([Guid]::NewGuid().ToString())

## Make sure TLS 1.2 is used
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

## Create temp directory
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
    ## Fetch latest release JSON metadata
    Write-Host "Fetching latest release info from GitHub..."
    $release = Invoke-RestMethod -Uri $apiUrl

    ## Find Windows x86_64 zip asset
    $asset = $release.assets | Where-Object { $_.name -match "Windows_x86_64.zip" } | Select-Object -First 1
    if (-not $asset) {
        Write-Error "No Windows x86_64 ZIP asset found in latest release."
        exit 1
    }
    $zipUrl = $asset.browser_download_url
    $zipPath = Join-Path $tempDir $asset.name

    ## Download the ZIP asset
    Write-Host "Downloading $($asset.name)..."
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

    ## Extract ZIP
    Write-Host "Extracting..."
    Expand-Archive -Path $zipPath -DestinationPath $tempDir

    ## Locate soft.exe
    $softExePath = Get-ChildItem -Path $tempDir -Filter $exeName -Recurse -File | Select-Object -First 1
    if (-not $softExePath) {
        Write-Error "soft.exe not found in extracted archive."
        exit 1
    }

    ## Create install directory if missing
    if (-not (Test-Path -Path $installDir)) {
        Write-Host "Creating install directory $installDir"
        New-Item -ItemType Directory -Path $installDir | Out-Null
    }

    ## Copy soft.exe to install dir
    $destPath = Join-Path $installDir $exeName
    Write-Host "Installing soft CLI to $destPath..."
    Copy-Item -Path $softExePath.FullName -Destination $destPath -Force

    ## Check if install dir in PATH, add user PATH if missing
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $currentPath.Split(";") -contains $installDir) {
        Write-Host "Adding $installDir to user PATH."
        $newPath = "$currentPath;$installDir"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "Please restart your shell or log off and back on for PATH changes to take effect."
    } else {
        Write-Host "$installDir is already in the PATH."
    }

    Write-Host "Installation completed successfully."
    try {
        & $destPath --version
    } catch {
        Write-Warning "Could not print soft-serve version. Make sure the executable is in your `$PATH. Soft serve was installed to: $installDir"
        exit 1
    }
}
finally {
    ## Cleanup temp dir
    Remove-Item -Recurse -Force -Path $tempDir
}
