$Location = (Get-Location).Path
$ParentPath = Split-Path -Path $Location -Parent
$ConfigFolder = "$ParentPath/proxmolito-config"

if (!(Test-Path -Path $ConfigFolder)) {
    Write-Hoss "The folder $ConfigFolder does not exist"
    Write-Host "Creating the folder $ConfigFolder" -ForegroundColor Green
    New-Item -ItemType Directory -Path $ConfigFolder | Out-Null
}