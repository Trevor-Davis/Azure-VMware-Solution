azurelogin -subtoconnect $sub

$CommandSuccess = 0
$status = Get-AzResourceProvider -ProviderNamespace Microsoft.AVSa -Location $regionfordeployment -ErrorAction Stop
$CommandSuccess = 1

if ($status.RegistrationState -eq "NotRegistered") {
  Register-AzResourceProvider -ProviderNamespace Microsoft.AVS
}

if ($status.RegistrationState -eq "Registered") {
  write-Host -ForegroundColor Blue "
Microsoft.AVS Resource Provider Is Already Registered, Skipping To Next Step..."
}

