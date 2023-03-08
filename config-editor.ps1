. $PSScriptRoot\config.ps1

# Global settings
$SnapShot = Read-Host "Do you want to make a snapshot of the VM before the configuration? (y/n)"
if ($SnapShot -like "y") { $SnapShot = $true} else { $SnapShot = $false }

$Memory = Read-Host "Enter the default memory for the VM in MB, (default: 2048)"
if ($Memory -eq "") { $Memory = 2048 } else { $Memory = [int]$Memory }

$MaxCPUCores = [int]((((lscpu | egrep "NUMA|CPU/(s/)")[1]).Split(":")[1] -split "\s{1,}")[1]).Split("-")[1] + 1
Write-Host "The Maximum number of CPU cores: $MaxCPUCores" -ForegroundColor Yellow | Out-Host 
[int]$CPU = Read-Host "Enter the default number of CPUs for the VM, (default: 2)"

if ($CPU -eq "") { $CPU = 2 } else {
    while ($CPU -gt $MaxCPUCores) {
    Write-Host "The number of CPUs ($CPU) is greater than the maximum number of CPU cores ($MaxCPUCores)" -ForegroundColor Red
    [int]$CPU = Read-Host "Enter the default number of CPUs for the VM, (default: 2)"
    if ($CPU -eq "") { $CPU = 2 }
    }
}

$DiskSize = Read-Host "Enter the default disk size for the VM in GB, (default: 32)"
if ($DiskSize -eq "") { $DiskSize = "32G" } else { $DiskSize = "$([int]$DiskSize)G" }

$HardwareDefault = Read-Host "Do you want to use this hardware settings as default? (y/n)"
if ($HardwareDefault -like "y") { $HardwareDefault = $true} else { $HardwareDefault = $false }

# CloudInit settings
$CloudInitUserName = Read-Host "Enter the default username for the cloud-init configuration"

write-host "Enter the path for default public key for the cloud-init configuration"
$CloudInitPublicKey = Read-Host "Press Enter for default public key (~/.ssh/id_rsa.pub) or enter the path for the public key"
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

# VM Network settings
$vmbr = Read-Host "Enter the default bridge for the VM network, (default: vmbr1)"
if ($vmbr -eq "") { $vmbr = "vmbr1" }

$IPSettings = Read-Host "Would you like to use DHCP or Static IP? (dhcp/static)"
if ($IPSettings -like "static") {
    $IP4Address = "static"
    $IP6Address = "static"

} else {
    $IP4Address = "DHCP"
    $IP6Address = "DHCP"
}

$CloudInitDefault = Read-Host "Do you want to use this as default cloud-init settings? (y/n)"
if ($CloudInitDefault -like "y") { $CloudInitDefault = $true} else { $CloudInitDefault = $false }


$ConfigFile = "$ConfigFolder/config.json"
$Config = [PSCustomObject]@{
    # Global settings
    Global = [PSCustomObject]@{
        HostName = hostname
        AppFolder = $PSScriptRoot
        ConfigFolder = $ConfigFolder
        # Default if the user want to make a snapshot of the VM before the configuration
        SnapShot = $false
    }
    # VM settings
    VM = [PSCustomObject]@{
        Hardware = [PSCustomObject]@{
            # Hardware settings
            UseAsDefault = $HardwareDefault
            Memory = $Memory
            Cores = $CPU
            DiskSize = $DiskSize
        }
        # CloudInit settings
        CloudInit = [PSCustomObject]@{
            UseAsDefault = $CloudInitDefault
            UserName = $CloudInitUserName
            PublicKey = $CloudInitPublicKey

            Bridge = $VMBR
            IPV4 = $IP4Address
            IPV6 = $IP6Address
        }
    }
}

Write-Host "Saving the file $ConfigFile..." -ForegroundColor Green
$Config | ConvertTo-Json -Depth 5 | Out-File -FilePath $ConfigFile -Encoding UTF8 -Force
Write-Host "The file $ConfigFile saved successfully." -ForegroundColor Green