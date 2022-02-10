remove-item $env:TEMP\AVSDeploy\*.*
mkdir $env:TEMP\AVSDeploy

<#$filename = ConnectToAzure.ps1
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
Invoke-Expression $env:TEMP\AVSDeploy\$filename

$filename = validatesubready.ps1
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
Invoke-Expression $env:TEMP\AVSDeploy\$filename

$filename = DefineResourceGroup.ps1
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
Invoke-Expression $env:TEMP\AVSDeploy\$filename

$filename = kickoffdeploymentofavsprivatecloud.ps1
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
Invoke-Expression $env:TEMP\AVSDeploy\$filename

$filename = ConnectAVSExrToVnet.ps1
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
Invoke-Expression $env:TEMP\AVSDeploy\$filename
#>
$filename = "ConnectAVSExrToOnPremExr.ps1"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
. "$env:TEMP\AVSDeploy\$filename"

$filename = "addhcx.ps1"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
. "$env:TEMP\AVSDeploy\$filename"


