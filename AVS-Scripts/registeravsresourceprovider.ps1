
#variables
$avsregion = $global:regionfordeployment
$avssub = $global:avssub
$tenant = ""

#DO NOT MODIFY BELOW THIS LINE #################################################

#Azure Login  
  

$filename = "Function-azurelogin.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$filename

if ($tenant -ne "") {
  azurelogin -subtoconnect $sub -tenanttoconnect $tenant
}
else {
  azurelogin -subtoconnect $sub 
}

#Execution

$test = Get-AzResourceProvider -ProviderNamespace Microsoft.AVS -Location $avsregion -ErrorAction SilentlyContinue

if ($test.RegistrationState -eq "Registered") {
write-Host -ForegroundColor Blue "
Microsoft.AVS Resource Provider Is Already Registered"
  }
  
if ($test.RegistrationState -eq "NotRegistered") {
write-host -foregroundcolor Yellow "
Registering Microsoft.AVS Resource Provider"
Register-AzResourceProvider -ProviderNamespace Microsoft.AVS

$test = Get-AzResourceProvider -ProviderNamespace Microsoft.AVS -Location $avsregion -ErrorAction SilentlyContinue
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