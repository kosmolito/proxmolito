. $PSScriptRoot\config.ps1
function Show-Menu {
    param (
        [string]$Title
    )
    $VMSelected | Format-table -Property VMName,DomainName,IPAddress,DNSAddress,NetworkSwitches
    Write-Host "================ $Title ================"
    
    Write-Host " 1: Deploy Ubuntu Server VM" -ForegroundColor Green
    Write-Host " 2: Install Required packaes and update the VM" -ForegroundColor Green
    Write-Host " 3: Prepare VM for k8s" -ForegroundColor Green
    Write-Host " 4: Clean VM and make Template" -ForegroundColor Green
    Write-Host " 5: NAT Network Deployment" -ForegroundColor Green
    Write-Host "99: Change the user config settings" -ForegroundColor Green
    Write-Host " B: Back to main menu" -ForegroundColor Green
    Write-Host " C: Clear the screen" -ForegroundColor Green
    Write-Host " Q: To quit" -ForegroundColor Green
}


do {
    Show-Menu -Title "P R O X M O L I T O"
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
            ################## Install Required packaes and update the VM ###################
            Write-Host "Installing Required packaes and update the VM" -ForegroundColor Green
            If ($Config.VM.Hardware.SnapShot -eq $true) {
                $SnapDate = Get-Date -Format "yyyy_MM_dd_HHmm"
                Write-Host "Creating a snapshot of the VM" -ForegroundColor Green
                $VMID = Read-Host "Enter the VM ID"
                write-host  "Allowed Characters: [A-Z],[a-z][0-9],[_]" -ForegroundColor Yellow | Out-Host
                write-host "[min character: 2],[Must start with letter]" -ForegroundColor Yellow | Out-Host
                $SnapShotName = Read-Host -Prompt "Enter the snapshot name"
                if ($SnapShotName -like "") {
                    $SnapShotName = "Before_Post_Deployment_$SnapDate"
                }

                Write-Host "Creating a snapshot of the VMID $VMID with the name $SnapShotName..."
                qm snapshot $VMID $SnapShotName
                if (!($?)) {
                    write-host "Error creating the snapshot, press any key to continue" -ForegroundColor Red
                    Pause
                } else {
                    write-host "Snapshot created, press any key to continue" -ForegroundColor Green
                    Pause
                }
            }

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
            ################## Prepare VM for k8s ###################
            Write-Host "Prepare VM for k8s" -ForegroundColor Green
            If ($Config.VM.Hardware.SnapShot -eq $true) {
                $SnapDate = Get-Date -Format "yyyy_MM_dd_HHmm"
                Write-Host "Creating a snapshot of the VM" -ForegroundColor Green
                $VMID = Read-Host "Enter the VM ID"
                write-host  "Allowed Characters: [A-Z],[a-z][0-9],[_]" -ForegroundColor Yellow | Out-Host
                write-host "[min character: 2],[Must start with letter]" -ForegroundColor Yellow | Out-Host
                $SnapShotName = Read-Host -Prompt "Enter the snapshot name"
                if ($SnapShotName -like "") {
                    $SnapShotName = "Before_Post_Deployment_$SnapDate"
                }

                Write-Host "Creating a snapshot of the VMID $VMID with the name $SnapShotName..."
                qm snapshot $VMID $SnapShotName
                if (!($?)) {
                    write-host "Error creating the snapshot, press any key to continue" -ForegroundColor Red
                    Pause
                } else {
                    write-host "Snapshot created, press any key to continue" -ForegroundColor Green
                    Pause
                }
            }

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

            If ($Config.VM.Hardware.SnapShot -eq $true) {
                $SnapDate = Get-Date -Format "yyyy_MM_dd_HHmm"
                Write-Host "Creating a snapshot of the VM" -ForegroundColor Green
                $VMID = Read-Host "Enter the VM ID"
                write-host  "Allowed Characters: [A-Z],[a-z][0-9],[_]" -ForegroundColor Yellow | Out-Host
                write-host "[min character: 2],[Must start with letter]" -ForegroundColor Yellow | Out-Host
                $SnapShotName = Read-Host -Prompt "Enter the snapshot name"
                if ($SnapShotName -like "") {
                    $SnapShotName = "Before_Post_Deployment_$SnapDate"
                }

                Write-Host "Creating a snapshot of the VMID $VMID with the name $SnapShotName..."
                qm snapshot $VMID $SnapShotName
                if (!($?)) {
                    write-host "Error creating the snapshot, press any key to continue" -ForegroundColor Red
                    Pause
                } else {
                    write-host "Snapshot created, press any key to continue" -ForegroundColor Green
                    Pause
                }
            }

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
            Write-Host "Machine ID cleaned, You can now convert it to a Template." -ForegroundColor Green
            Pause

        }

        "5" 
        {
            & $Location\nat-network-deployment.ps1
        }

        "99"
        {
            Write-Host "Your current config settings:" -ForegroundColor Green
            $ConfigView = ($Config).Global,($Config).VM.Hardware,($Config).VM.CloudInit | Format-List
            $ConfigView | Out-Host
            $Confirmation = Read-Host "Do you want to change the settings? (y/n)"
            if ($Confirmation -like "y") {
                & $Location/config-editor.ps1
            }
        }
        
        Default {}
    }


} until (
    $Selection -eq "q"
)