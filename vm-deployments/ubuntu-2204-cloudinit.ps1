# Load the config script
$ParentFolder = Split-Path $PSScriptRoot -Parent
. $ParentFolder/config.ps1

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
$FilePath = "/$ConfigFolder/$FileName"
pvesm status | Out-Host
$StorageName = Read-Host "Enter the storage name (eg. data)"

if ($Config.CloudInit.UseDefault -eq $false) {

Write-Host "Available network bridges:" -ForegroundColor Green | Out-Host
$AvailableBridges | Out-Host
$vmbr = Read-Host "Enter the network bridge (eg. vmbr1)"

$IPV4 = Read-Host "Enter the IP address and cidr for the VM (eg. 10.10.10.20/24), leave blank for DHCP"
if ($IPV4 -eq "") { $IPV4 = "dhcp" } else { $IPV4Gateway = Read-Host "Enter the gateway for the VM" }

$CloudInitUserName = Read-Host "Enter the username for VM (Cloud-init)"
$CloudInitPassword = Read-Host "Enter a password for the user (Cloud-init)" -MaskInput

$CloudInitPublicKey = Read-Host "Do you want to add a SSH public key (Cloud-init)? (y/n)"
    if ($CloudInitPublicKey -eq "y") {
        Write-Host "Enter the path to the SSH public key (Cloud-init)" -ForegroundColor Green
        $CloudInitPublicKey = Read-Host "Leave blank for default (~/.ssh/id_rsa.pub)"
        if ($CloudInitPublicKey -eq "") {
            $CloudInitPublicKey = "~/.ssh/id_rsa.pub"
            if (!(Test-Path $CloudInitPublicKey)) {
                Write-Host "The file $CloudInitPublicKey does not exist" -ForegroundColor Red
                $CloudInitPublicKey = Read-Host "Do you want to create a SSH key pair? (y/n)"
                if ($CloudInitPublicKey -like "y") {
                    $SSHComment = Read-Host "Enter a comment for the SSH key pair"
                    ssh-keygen -t rsa -C "$SSHComment"
                    $CloudInitPublicKey = "~/.ssh/id_rsa.pub"
                }
            }

        } else {
            $isExistCloudInitPublicKey =  Test-Path $CloudInitPublicKey
            
            while ($isExistCloudInitPublicKey -eq $false) {
                Write-Host "The file $CloudInitPublicKey does not exist" -ForegroundColor Red
                $CloudInitPublicKey = Read-Host "Enter the path to the SSH public key (Cloud-init)"
                $isExistCloudInitPublicKey =  Test-Path $CloudInitPublicKey
            }
        }
    }

} else {
    $CloudInitUserName = $Config.VM.CloudInit.UserName
    $CloudInitPassword = $Config.VM.CloudInit.Password
    $CloudInitPublicKey = $Config.VM.CloudInit.PublicKey
    $vmbr = $Config.VM.CloudInit.Bridge
    $IPV4 = $Config.VM.CloudInit.IPV4
}


if (Test-Path $FilePath) {
    Write-Host "File [$($FilePath)] already exists, ignoring download"
} else {
    Write-Host "File [$($FilePath)] does not exist, downloading.."
    wget $UrlLink -P $ConfigFolder
    # Convert the image to qcow2 format
    Move-Item $ConfigFolder/$LinkFileName $ConfigFolder/$FileName
    qemu-img resize $FileName $DiskSize
}

if ($Config.VM.Hardware.UseAsDefault -eq $false) {
    Write-Host "The Maximum number of CPU cores is: $CPUCores" -ForegroundColor Yellow | Out-Host 
    $Cores = Read-Host "Enter the number of CPU cores (eg. 2)"
    $Memory = Read-Host "Enter the amount of memory in MB (eg. 2048)"
    $DiskSize = Read-Host "Enter the size of the disk (eg. 32G)"

    $Cores = [int]$Cores
    $Memory = [int]$Memory
} else {
    $Cores = $Config.VM.Hardware.Cores
    $Memory = $Config.VM.Hardware.Memory
    $DiskSize = $Config.VM.Hardware.DiskSize
}

# Create the VM with cloud-init drive
$Net = "virtio,bridge=$($vmbr)"
qm create $VMID --name $VMName --autostart 1 --memory $Memory --sockets 1 --cores $Cores --agent 1 --startup order=0 `
--net0 $Net --serial0 socket --vga serial0 --scsihw virtio-scsi-pci --ide0 $StorageName":cloudinit,media=cdrom" --ide2 none,media=cdrom

# Set the cloud-init user and password
qm set $VMID --ciuser $CloudInitUserName --cipassword $CloudInitPassword 

# Set the SSH key for the VM if it exist in the home directory of the user
if (Test-Path $CloudInitPublicKey) {
    qm set $VMID --sshkey $CloudInitPublicKey
}

# Set the VM to use DHCP
if ($IPV4 -eq "dhcp") {
    qm set $VMID --ipconfig0 ip=dhcp,ip6=dhcp
} else {
    # Set the VM to use a static IP
    qm set $VMID --ipconfig0 ip=$IPV4,gw=$IPV4Gateway,ip6=dhcp
}

# Import the image to VM
qm importdisk $VMID $FilePath $StorageName

# Attach the disk to the VM
qm set $VMID --scsi0 $StorageName":vm-$VMID-disk-0,discard=on,iothread=1,size=$DiskSize,ssd=1"

# Fix the boot order, cloud-init needs to be the first boot device
qm set $VMID --boot order="ide2;scsi0;net0;ide0"

Write-Host "VM created successfully!"

# Start the VM
qm start $VMID