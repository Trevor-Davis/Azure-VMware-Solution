<# 
$regionfordeployment = ""
$sub = ""
$filename = "azureloginfunction.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVSSimplifiedDeployment/$filename" -OutFile $env:TEMP\AVSDeploy\$filename
Clear-Host
. $env:TEMP\AVSDeploy\$filename
#>

azurelogin -subtoconnect $sub

$status = Get-AzResourceProvider -ProviderNamespace Microsoft.AVS -Location $regionfordeployment -ErrorAction SilentlyContinue

if ($status.RegistrationState -eq "NotRegistered") {
  Register-AzResourceProvider -ProviderNamespace Microsoft.AVS
}

if ($status.RegistrationState -eq "Registered") {
  write-Host -ForegroundColor Blue "
Microsoft.AVS Resource Provider Is Already Registered, Skipping To Next Step..."
}
