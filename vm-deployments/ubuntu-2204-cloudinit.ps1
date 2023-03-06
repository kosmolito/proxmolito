Write-Host "Deploy Ubuntu Server VM" -ForegroundColor Green | Out-Host
$VMID = Read-Host "Enter the VM ID (eg. 999), Make sure it is available!"
# Check if the VMID already exist
$VMIDExist = qm status $VMID
while ($VMIDExist.Count -ne 0) {
   $VMID = Read-Host "VMID already exist! Please chose another number"
    $VMIDExist = qm status $VMID
}
