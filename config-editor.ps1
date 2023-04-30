. $PSScriptRoot\config.ps1

# Global settings
$SnapShotDefault = Read-Host "Do you want to make a snapshot of the VM before the configuration? (y/n)"
if ($SnapShotDefault -like "y") { $SnapShotDefault = $true} else { $SnapShotDefault = $false }

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
$CloudInitPublicKey = Read-Host "Enter the path for the public key (blank for ~/.ssh/id_rsa.pub)"
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
$AvailableBridge | Out-Host
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

################### SSH Config settings
$SSHConfigFilePath = "~/.ssh/config"
$SSHConfigFile = Get-Content -Path $SSHConfigFilePath
$AvailableBridges = Get-Content -Path /etc/network/interfaces | Where-Object {$_ -match "iface " -or $_ -match "address "}

$AddHost = Read-Host "Do you want to add a new host/nework to SSH config file? (y/n)"
if ($AddHost -eq "y") {
    $AvailableBridges | out-host
    Write-Host "eg. 10.10.10.12 for a single host or 10.10.10.* for a network" -ForegroundColor Yellow
    $HostAddress = Read-Host "Enter the IP address of the host/network"
    $User = Read-Host "Enter the username (blank for $CloudInitUserName)"
    if ($User -eq "") { $User = $CloudInitUserName } else { $User = $User }

    $Port = Read-Host "Enter the port (blank for 22)"
    if ($Port -eq "") { $Port = 22 } else { $Port = $Port }
    $IdentityFile = Read-Host "Enter the path to the private key (blank for ~/.ssh/id_rsa)"
    if ($IdentityFile -eq "") { $IdentityFile = "~/.ssh/id_rsa" } else { $IdentityFile = $IdentityFile }
$NewHostSettings = @"


Host $HostAddress
        User $User
        Port $Port
        IdentityFile $IdentityFile
"@
    $HostFound = 0
    $SSHConfigFile | ForEach-Object {
        if ($_ -match "Host $HostAddress") {
            $HostFound = $HostFound + 1
            write-host "$_ already exists in SSH config file" -ForegroundColor Yellow
        }
    }
    
    if ($HostFound -ne 0) {
        Write-Host "Host $HostAddress already exists in SSH config file" -ForegroundColor Yellow
    } else {
        Write-Host "Adding $HostAddress to SSH config file" -ForegroundColor Green
        $NewHostSettings | Out-File -FilePath $SSHConfigFilePath -Append
        Write-Host "Host $HostAddress added to SSH config file" -ForegroundColor Green
        Write-Host "SSH config file content:" -ForegroundColor Yellow
        Get-Content -Path $SSHConfigFilePath | Out-Host
    }
} else { Write-Host "No new host/network added to SSH config file" -ForegroundColor Yellow }

$ConfigFile = "$ConfigFolder/config.json"
$ConfigSettings = [PSCustomObject]@{
    # Global settings
    Global = [PSCustomObject]@{
        HostName = hostname
        AppFolder = $PSScriptRoot
        ConfigFolder = $ConfigFolder

    }
    # VM settings
    VM = [PSCustomObject]@{
        Hardware = [PSCustomObject]@{
            # Hardware settings
            UseAsDefault = $HardwareDefault
            Memory = $Memory
            Cores = $CPU
            DiskSize = $DiskSize
            # Default if the user want to make a snapshot of the VM before the configuration
            SnapShot = $SnapShotDefault
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
$ConfigSettings | ConvertTo-Json -Depth 5 | Out-File -FilePath $ConfigFile -Encoding UTF8 -Force
start-sleep -Seconds 2
$Config = $Config = Get-Content -Path $ConfigFile | ConvertFrom-Json -Depth 5
Write-Host "The file $ConfigFile saved successfully." -ForegroundColor Green