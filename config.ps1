# Check if the script is running on a Linux machine
if (!($IsLinux)) {
    Write-Host "This script is intended to be run on a Linux machine" -ForegroundColor Red
    exit
}

$Location = $PSScriptRoot
$ParentPath = Split-Path -Path $Location -Parent
$ConfigFolder = "$ParentPath/proxmolito-config"
$ConfigFile = "$ConfigFolder/config.json"

if (!(Test-Path -Path $ConfigFolder)) {

    Write-Host "Creating the config folder $ConfigFolder" -ForegroundColor Green
    New-Item -ItemType Directory -Path $ConfigFolder | Out-Null
    New-Item -ItemType File -Path "$ConfigFolder/config.json" | Out-Null

$WelCome = @"



#####################################################################################
##############################  Welcome to Proxmolito  ##############################

The main goal is to quickly deploy a virtual machines, setup networking,
and configure cloud-init without having to remember all the commands and options.

I am planning to add more features to proxmolito in the future, 
like the ability to create and configure containers and more. 

But for now, I am focusing on the main goal of proxmolito, 
which is to create and configure Virtual Machines.

I hope you find this project useful.
#####################################################################################
"@
Clear-Host
$WelCome | Out-Host
Pause

$CreateNATNetwork = Read-Host "Do you want to create a NAT network? (y/n)"
if ($CreateNATNetwork -like "y") {
    & $Location\nat-network-deployment.ps1
}

& $Location/config-editor.ps1

} else {
    $Config = Get-Content -Path $ConfigFile | ConvertFrom-Json -Depth 5
    $AvailableBridge = Get-Content -Path /etc/network/interfaces | Where-Object {$_ -match "iface " -or $_ -match "address " -or $_ -match "netmask "}
    $Date = Get-Date -Format "yyyy-MM-dd-HHmm"
}