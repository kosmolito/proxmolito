$Date = Get-Date -Format "yyyy-MM-dd-HHmm"
$IFPath = "/etc/network/interfaces"
$IFBackupPath = "/etc/network/interfaces-$Date.bak"
while (Test-Path $IFBackupPath) {
    $i = 1
    $IFBackupPath = "$IFBackupPath-$i"
}
Write-Host "Backing up interfaces file to $IFBackupPath"
Copy-Item $IFPath -Destination $IFBackupPath -Force

Write-Host "Here is your current interfaces file" -ForegroundColor Green
$IFFile = Get-Content -Path $IFPath
$IFFile | Out-Host
$NewIFName = Read-Host "Enter the name of the new interface you want to create (ex. vmbr1)"
$isIFExists = ip -f inet addr show $NewIFName.ToLower()
while ($isIFExists.Count -ne 0) {
    $NewIFName = Read-Host "Interface already exists, please enter a new name (ex. vmbr2)"
    $isIFExists = ip -f inet addr show $NewIFName.ToLower()
}

$NewIFIP = Read-Host "Enter the IP address of the new interface (ex. 10.10.10.1)"
$NewIFNetmask = Read-Host "Enter the netmask of the new interface (ex. 255.255.255.0)"

$RoutingIF = Read-Host "Enter the name of the interface you want to use for routing (ex. vmbr0)"
$isIFExists = ip -f inet addr show $RoutingIF.ToLower()
while ($isIFExists.Count -eq 0) {
    $RoutingIF = Read-Host "Interface doesn't exists, please enter a new name (ex. vmbr1)"
    $isIFExists = ip -f inet addr show $RoutingIF.ToLower()
}

# Create a variable Read-Host Validation for CIDR Notation between 1 and 32:
$CiderNotation = Read-Host "Enter the CIDR notation of the new interface (ex. 24)"
while ($CiderNotation -lt 1 -or $CiderNotation -gt 32) {
    $CiderNotation = Read-Host "Invalid CIDR notation, please enter a new value between 1 and 32 (ex. 24)"
}
$SubNet = $NewIFIP.Split(".")[0..2] -join "."
$SubNet = "$SubNet.0/$CiderNotation"
