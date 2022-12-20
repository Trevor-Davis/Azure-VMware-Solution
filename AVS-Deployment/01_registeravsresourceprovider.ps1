
azurelogin -subtoconnect $avssub

$test = Get-AzResourceProvider -ProviderNamespace Microsoft.AVS -Location $avsregion -ErrorAction SilentlyContinue

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
Microsoft.AVS Resource Provider Successfully Registered"
  }
}