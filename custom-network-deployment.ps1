$Date = Get-Date -Format "yyyy-MM-dd-HHmm"
$IFPath = "/etc/network/interfaces"
$IFBackupPath = "/etc/network/interfaces-$Date.bak"
while (Test-Path $IFBackupPath) {
    $i = 1
    $IFBackupPath = "$IFBackupPath-$i"
}
Write-Host "Backing up interfaces file to $IFBackupPath"
Copy-Item $IFPath -Destination $IFBackupPath -Force
