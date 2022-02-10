$sub = "1178f22f-6ce4-45e3-bd92-ba89930be5be"
$RGNewOrExisting = "Existing"
$rgfordeployment = "VirtualWorkloads-APAC-AzureCloud"
$regionfordeployment = "southeastasia"
$pcname = "AVS1-VirtualWorkloads-APAC-AzureCloud"
$addressblock = "10.1.0.0/22"
$skus = "AV36"
$numberofhosts = "3"
$internet = "Enabled"
$ExrGatewayForAVS = "ExRGW-VirtualWorkloads-APAC-Hub"
$ExRGWResourceGroup = "VirtualWorkloads-APAC-Hub"
$ExrGWforAVSResourceGroup = "VirtualWorkloads-APAC-Hub"
$ExrForAVSRegion = "southeastasia"
$OnPremExRCircuitSub = "3988f2d0-8066-42fa-84f2-5d72f80901da"
$NameOfOnPremExRCircuit = "tnt15-cust-p01-australiaeast-er"
$RGofOnPremExRCircuit = "Prod_AVS_RG" 



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

<#
$filename = "addhcx.ps1"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
. "$env:TEMP\AVSDeploy\$filename"
#>

