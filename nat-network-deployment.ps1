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

$IFConfigurations = @"

auto $NewIFName
iface $NewIFName inet static
        address  $NewIFIP
        netmask  $NewIFNetmask
        bridge_ports none
        bridge_stp off
        bridge_fd 0
post-up echo 1 >/proc/sys/net/ipv4/ip_forward
        post-up   iptables -t nat -A POSTROUTING -s '$SubNet' -o $RoutingIF -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '$SubNet' -o $RoutingIF -j MASQUERADE
"@

Write-Host "Here is the new interface configuration" -ForegroundColor Green
$IFConfigurations | Out-Host
$Confirm = Read-Host "Do you want to continue? (y/n)"
if ($Confirm -notlike "y") {
    Write-Host "Did not get confirmation! Exiting script" -ForegroundColor Red
    Pause
    Exit
}

write-host "updating interfaces file"
$IFConfigurations | Out-File -FilePath $IFPath -Append

Write-Host "Restarting networking.."
ifdown --exclude=lo -a && ifup --exclude=lo -a

Write-Host "Network interfaces updated!" -ForegroundColor Green

write-host "Here is your new interfaces file" -ForegroundColor Green
Get-Content -Path $IFPath
Pause