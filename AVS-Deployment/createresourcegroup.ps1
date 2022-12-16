
$test = Get-AzResourceGroup -Name $rgname -ErrorAction:Ignore

if($test.count -eq 1){
        write-host -foregroundcolor Blue "
$rgname Already Exists ... Skipping to Next Step"   

}


if($test.count -eq 0){
    $command = New-AzResourceGroup -Name $rgname -Location $regionfordeployment
    
    if ($command.ProvisioningState -ne "Succeeded")
    {Write-Host -ForegroundColor Red "Creation of the Resource Group $rgname Failed"
    Exit}

    write-host -foregroundcolor Green "
Success: AVS Private Cloud Resource Group $rgname Created"   

}





$test = Get-AzResourceGroup -Name $rgname -ErrorAction:Ignore

if ($test.RegistrationState -eq "Registered") {
write-Host -ForegroundColor Blue "
Microsoft.AVS Resource Provider Is Already Registered ... Skipping to Next Step"
  }
  
if ($test.RegistrationState -eq "NotRegistered") {
write-host -foregroundcolor Yellow "
Registering Microsoft.AVS Resource Provider"
Register-AzResourceProvider -ProviderNamespace Microsoft.AVS

$test = Get-AzResourceProvider -ProviderNamespace Microsoft.AVS -Location $regionfordeployment -ErrorAction SilentlyContinue
If(test.RegistrationState -eq "NotRegistered"){
Write-Host -ForegroundColor Red "
Microsoft.AVS Resource Provider Registration Failed"
Exit
}
else {
  write-Host -ForegroundColor Green "
  Microsoft.AVS Resource Provider Successfully Registered ... Skipping to Next Step"
  }
}




