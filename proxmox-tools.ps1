$Location = (Get-Location).Path

# Check if the script is running on a Linux machine
if (!($IsLinux)) {
    Write-Host "This script is intended to be run on a Linux machine" -ForegroundColor Red
    exit
}

function Show-Menu {
    param (
        [string]$Title
    )
    Write-Host -ForegroundColor red "Existing VM Selected To Configure"
    $VMSelected | Format-table -Property VMName,DomainName,IPAddress,DNSAddress,NetworkSwitches
    Write-Host "================ $Title ================"
    
    Write-Host "1: Deploy Ubuntu Server VM" -ForegroundColor Green
    Write-Host "2: Install Required packaes and update the VM" -ForegroundColor Green
    Write-Host "3: Prepare VM for k8s" -ForegroundColor Green
    Write-Host "4: Clean VM and make Template" -ForegroundColor Green
    Write-Host "B:" "Back to main menu" -ForegroundColor Green
    Write-Host "c:" "Clear the screen" -ForegroundColor Green
    Write-Host "Q: To quit" -ForegroundColor Green
}
