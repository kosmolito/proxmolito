$Location = (Get-Location).Path

# Check if the script is running on a Linux machine
if (!($IsLinux)) {
    Write-Host "This script is intended to be run on a Linux machine" -ForegroundColor Red
    exit
}
