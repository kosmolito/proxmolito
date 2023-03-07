$Location = (Get-Location).Path
$ParentPath = Split-Path -Path $Location -Parent
$ConfigFolder = "$ParentPath/proxmolito-config"



if (!(Test-Path -Path $ConfigFolder)) {

    Write-Host "Creating the folder $ConfigFolder" -ForegroundColor Green
    New-Item -ItemType Directory -Path $ConfigFolder | Out-Null

$WelCome = @"
###################################################################
#####################  Welcome to Proxmolito  #####################

The main goal is to quickly deploy a virtual machines, setup networking, 
and configure cloud-init without having to remember all the commands and options.

I am planning to add more features to proxmolito in the future, 
like the ability to create and configure containers and more. 

But for now, I am focusing on the main goal of proxmolito, 
which is to create and configure Virtual Machines.

I hope you find this project useful.
"@

$WelCome | Out-Host
Pause

$CreateNATNetwork = Read-Host "Do you want to create a NAT network? (y/n)"
if ($CreateNATNetwork -like "y") {
    & $Location\nat-network-deployment.ps1
}

& $Location/config-editor.ps1

} else {
    $Config = Get-Content -Path "$ConfigFolder/config.json" | ConvertFrom-Json -Depth 5
}