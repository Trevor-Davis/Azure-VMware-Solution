
$testforrg = Get-AzResourceGroup -Name $rgname -ErrorAction:Ignore

if($testforrg.count -eq 1){
        write-host -foregroundcolor Green "
$rgname Already Exists"   

}


if($testforrg.count -eq 0){
    $command = New-AzResourceGroup -Name $rgname -Location $regionfordeployment
    
    if ($command.ProvisioningState -ne "Succeeded")
    {Write-Host -ForegroundColor Red "Creation of the Resource Group $rgname Failed"
    Exit}

    write-host -foregroundcolor Green "
Success: AVS Private Cloud Resource Group $rgname Created"   

}