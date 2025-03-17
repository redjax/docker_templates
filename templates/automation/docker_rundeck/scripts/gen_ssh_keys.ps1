Param(
    [Parameter(Mandatory=$false, HelpMessage = "Path where SSH keys will be outputted")]
    [string] $OutputDir = "./ssh",
    [Parameter(Mandatory=$false, HelpMessage = "Name of SSH key")]
    [string] $KeyName = "rundeck_id_rsa"
)

$OutputPath = Join-Path -Path $OutputDir -ChildPath $KeyName
if (Test-Path $OutputPath) {
    Write-Host "SSH keys already exist at $OutputPath. Skipping key generation."
    exit(0)
}

if ( -not (Get-Command ssh-keygen -ErrorAction SilentlyContinue) ) {
    Write-Error "ssh-keygen is not installed"
    exit(1)
}

Write-Host "Generating SSH key, outputting to $($OutputPath)"
try {
    ssh-keygen -t rsa -b 4096 -f $OutputPath -P ""
} catch {
    Write-Error "Failed to generate SSH keys: $($_.Exception.Message)"
    exit(1)
}