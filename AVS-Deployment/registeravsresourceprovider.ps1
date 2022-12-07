
$status = Get-AzResourceProvider -ProviderNamespace Microsoft.AVS -Location $regionfordeployment -ErrorAction SilentlyContinue

if ($status.RegistrationState -eq "NotRegistered") {
  Register-AzResourceProvider -ProviderNamespace Microsoft.AVS
}

if ($status.RegistrationState -eq "Registered") {
  write-Host -ForegroundColor Blue "
Microsoft.AVS Resource Provider Is Already Registered, Skipping To Next Step..."
}
