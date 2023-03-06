$Location = (Get-Location).Path

# Check if the script is running on a Linux machine
if (!($IsLinux)) {
    Write-Host "This script is intended to be run on a Linux machine" -ForegroundColor Red
    exit
}

function Show-Menu {
    param (
        [string]$Title
    )
    Write-Host -ForegroundColor red "Existing VM Selected To Configure"
    $VMSelected | Format-table -Property VMName,DomainName,IPAddress,DNSAddress,NetworkSwitches
    Write-Host "================ $Title ================"
    
    Write-Host "1: Deploy Ubuntu Server VM" -ForegroundColor Green
    Write-Host "2: Install Required packaes and update the VM" -ForegroundColor Green
    Write-Host "3: Prepare VM for k8s" -ForegroundColor Green
    Write-Host "4: Clean VM and make Template" -ForegroundColor Green
    Write-Host "5: NAT Network Deployment" -ForegroundColor Green
    Write-Host "B: Back to main menu" -ForegroundColor Green
    Write-Host "c: Clear the screen" -ForegroundColor Green
    Write-Host "Q: To quit" -ForegroundColor Green
}


do {
    Show-Menu -Title "Proxmox VM Utilities"
    $Selection = Read-Host "Please make a selection"
    # Get the current location
    $Location = Get-Location
    switch ($Selection) {
        "c" { Clear-Host }
        "1" 
        {
            & $Location\vm-deployments\ubuntu-2204-cloudinit.ps1
        }

        "2" 
        {
            Write-Host "Install Required packaes and update the VM" -ForegroundColor Green | Out-Host
            if ($VMIP -like "") {
                $VMIP = Read-Host "Enter the IP address for the VM"
            } else {
                Write-Host "Using the IP address from the previous step: $VMIP" -ForegroundColor Yellow
                Pause
            }

            $SourceFolder = "$($Location)/bash-scripts"
            $SourceFileName = "vm-post-deployment.sh"
            $SourceFile = "$SourceFolder/$SourceFileName"
            $DestinationFile = "/tmp/$SourceFileName"

            scp -o "StrictHostKeyChecking=no" $SourceFile "$($VMIP):$($DestinationFile)"
            ssh $VMIP $DestinationFile
        }


        "3" 
        {
            Write-Host "Installing K8s and all the dependencies" -ForegroundColor Green
            if ($VMIP -like "") {
                $VMIP = Read-Host "Enter the IP address for the VM"
            } else {
                Write-Host "Using the IP address from the previous step: $VMIP" -ForegroundColor Yellow
                Pause
            }
            

            $SourceFolder = "$($Location)/bash-scripts"
            $SourceFileName = "k8s-deployment.sh"
            $SourceFile = "$SourceFolder/$SourceFileName"
            $DestinationFile = "/tmp/$SourceFileName"

            scp -o "StrictHostKeyChecking=no" $SourceFile "$($VMIP):$($DestinationFile)"
            ssh $VMIP $DestinationFile

        }


        "4"
        {
            ################## Clean the machine to make a Template ###################
            Write-Host "Cleaning the machine to make a Template" -ForegroundColor Green
            if ($VMIP -like "") {
                $VMIP = Read-Host "Enter the IP address for the VM"
            } else {
                Write-Host "Using the IP address from the previous step: $VMIP" -ForegroundColor Yellow
                Pause
            }

            $SourceFolder = "$($Location)/bash-scripts"
            $SourceFileName = "machine-id-clean.sh"
            $SourceFile = "$SourceFolder/$SourceFileName"
            $DestinationFile = "/tmp/$SourceFileName"

            scp -o "StrictHostKeyChecking=no" $SourceFile "$($VMIP):$($DestinationFile)"
            ssh $VMIP $DestinationFile

        }

        "5" 
        {
            & $Location\nat-network-deployment.ps1
        }
        
        Default {}
    }


} until (
    $Selection -eq "q"
)