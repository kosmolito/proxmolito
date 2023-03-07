. ./config.ps1

# Global settings
$SnapShot = Read-Host "Do you want to make a snapshot of the VM before the configuration? (y/n)"
if ($SnapShot -like "y") { $SnapShot = $true} else { $SnapShot = $false }

# CloudInit settings
$CloudInitUserName = Read-Host "Enter the default username for the cloud-init configuration"
$CloudInitPassword = Read-Host "Enter the default password for the cloud-init configuration" -MaskInput

write-host "Enter the path for default public key for the cloud-init configuration"
$CloudInitPublicKey = Read-Host "Enter for default public key (~/.ssh/id_rsa.pub)"
if ($CloudInitPublicKey -eq "") { $CloudInitPublicKey = "~/.ssh/id_rsa.pub" } else {
    if (!(Test-Path -Path $CloudInitPublicKey)) {
        Write-Host "The file $CloudInitPublicKey does not exist" -ForegroundColor Red
        if (Test-Path "~/.ssh/id_rsa.pub") {
            write-host "Using the default public key (~/.ssh/id_rsa.pub)"
            $CloudInitPublicKey = "~/.ssh/id_rsa.pub"
        } else {
            write-host "Could not find default public key, Using an empty public key"
            $CloudInitPublicKey = ""
        }
    }
}
$CloudInitDefault = Read-Host "Do you want to use the default cloud-init settings? (y/n)"
if ($CloudInit -like "y") { $CloudInit = $true} else { $CloudInit = $false }

# VM Network settings
$vmbr = Read-Host "Enter the default bridge for the VM network, (default: vmbr1)"
if ($vmbr -eq "") { $vmbr = "vmbr1" }

$IPAddress = Read-Host "Enter the default IP address for the VM network, (default: DHCP)"
if ($IPAddress -eq "") { $IPAddress = "DHCP" }

$VMNetworkDefault = Read-Host "Do you want to use the default network settings? (y/n)"
if ($VMNetwork -like "y") { $VMNetwork = $true} else { $VMNetwork = $false }


$ConfigFile = "$ConfigFolder/config.json"
$Config = [PSCustomObject]@{
    # Global settings
    Global = [PSCustomObject]@{
        HostName = hostname
        AppFolder = (Get-Location).Path
        ConfigFolder = $ConfigFolder
        # Default if the user want to make a snapshot of the VM before the configuration
        SnapShot = $false
    }
    # VM settings
    VM = [PSCustomObject]@{
        UseDefault = $false
        # Hardware settings
        Memory = 2048
        Cores = 2
        DiskSize = "32G"
        # CloudInit settings
        CloudInit = [PSCustomObject]@{
            UseDefault = $CloudInitDefault
            UserName = $CloudInitUserName
            Password = $CloudInitPassword
            PublicKey = $CloudInitPublicKey
        }
        # Network settings
        VMNetwork = [PSCustomObject]@{
            UseDefault = $VMNetworkDefault
            Bridge = $VMBR
            IP = "DHCP"
            IP6 = "DHCP"
            Netmask = "255.255.255.0"
            Gateway = ""
            DNS = ""
        }
    }
}

Write-Host "Saving the file $ConfigFile..." -ForegroundColor Green
$Config | ConvertTo-Json -Depth 5 | Out-File -FilePath $ConfigFile -Encoding UTF8 -Force
Write-Host "The file $ConfigFile saved successfully." -ForegroundColor Green