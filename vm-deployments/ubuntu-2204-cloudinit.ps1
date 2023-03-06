Write-Host "Deploy Ubuntu Server VM" -ForegroundColor Green | Out-Host
$VMID = Read-Host "Enter the VM ID (eg. 999), Make sure it is available!"
# Check if the VMID already exist
$VMIDExist = qm status $VMID
while ($VMIDExist.Count -ne 0) {
   $VMID = Read-Host "VMID already exist! Please chose another number"
    $VMIDExist = qm status $VMID
}

$VMName = Read-Host "Enter a name for the VM"
$Memory = 2048
$Cores = 2
$DiskSize = "32G"
$UrlLink = "https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img"
# Get the file name from the URL
$LinkFileName = Split-Path $UrlLink -Leaf
$FileName = "ubuntu-2204.qcow2"
$FilePath = "/$Location/$FileName"
pvesm status | Out-Host
$StorageName = Read-Host "Enter the storage name (eg. data)"
$CloudInitUserName = Read-Host "Enter the username for VM (Cloud-init)"
$CloudInitPassword = Read-Host "Enter a password for the user (Cloud-init)" -MaskInput
$CloudInitPublicKey = "~/.ssh/id_rsa.pub"

if (Test-Path $FilePath) {
    Write-Host "File [$($FilePath)] already exists, ignoring download"
} else {
    Write-Host "File [$($FilePath)] does not exist, downloading.."
    wget $UrlLink
    # Convert the image to qcow2 format
    Move-Item $LinkFileName $FileName
    qemu-img resize $FileName $DiskSize
}

# Create the VM with cloud-init drive
qm create $VMID --name $VMName --autostart 1 --memory $Memory --sockets 1 --cores $Cores --agent 1 --startup order=0 `
--net0 virtio,bridge=vmbr1 --serial0 socket --vga serial0 --scsihw virtio-scsi-pci --ide0 $StorageName":cloudinit,media=cdrom" --ide2 none,media=cdrom

# Set the cloud-init user and password
qm set $VMID --ciuser $CloudInitUserName --cipassword $CloudInitPassword 

# Set the SSH key for the VM if it exist in the home directory of the user
if (Test-Path $CloudInitPublicKey) {
    qm set $VMID --sshkey ~/.ssh/id_rsa.pub
}

# Set the VM to use DHCP
qm set $VMID --ipconfig0 ip=dhcp,ip6=dhcp

