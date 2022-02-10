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


<#$variablefile = "avspcdeploy-variables.ps1"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$variablefile -OutFile $env:TEMP\AVSDeploy\$variablefile
. "$env:TEMP\AVSDeploy\$variablefile"
#>
Select-AzSubscription -SubscriptionId $sub
Write-Host -ForegroundColor Yellow "Building Global Reach connection from $pcname to the on-premises Express Route $NameOfOnPremExRCircuit..."
write-Host "hello3"
New-AzVMwareGlobalReachConnection -Name $NameOfOnPremExRCircuit -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -AuthorizationKey "490b170e-1ae8-404d-bafc-333eaa0e6cde" -PeerExpressRouteResourceId "/subscriptions/52d4e37e-0e56-4016-98de-fe023475b435/resourceGroups/tnt15-cust-p01-australiaeast/providers/Microsoft.Network/expressRouteCircuits/tnt15-cust-p01-australiaeast-er"

$provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.CircuitConnectionStatus

while ("Connected" -ne $currentprovisioningstate)
{
write-Host -ForegroundColor Yellow "Current Status of Global Reach Connection: $currentprovisioningstate"
Start-Sleep -Seconds 10
$provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.CircuitConnectionStatus}

if("Connected" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Green "Success: AVS Private Cloud $pcname is Connected via Global Reach to $NameOfOnPremExRCircuit"
}  



<#
Select-AzSubscription -SubscriptionId $OnPremExRCircuitSub

$OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
Add-AzExpressRouteCircuitAuthorization -Name "For-$pcname" -ExpressRouteCircuit $OnPremExRCircuit
Set-AzExpressRouteCircuit -ExpressRouteCircuit $OnPremExRCircuit

Write-Host -ForegroundColor Green "
Success: Auth Key Genereated for AVS On Express Route $NameOfOnPremExRCircuit"

$OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
$OnPremCircuitAuthDetails = Get-AzExpressRouteCircuitAuthorization -ExpressRouteCircuit $OnPremExRCircuit | Where-Object {$_.Name -eq "For-$pcname"}
$OnPremCircuitAuth = $OnPremCircuitAuthDetails.AuthorizationKey

Select-AzSubscription -SubscriptionId $sub
New-AzVMwareGlobalReachConnection -Name $NameOfOnPremExRCircuit -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -AuthorizationKey $OnPremCircuitAuth -PeerExpressRouteResourceId $OnPremExRCircuit.Id

$provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.CircuitConnectionStatus

while ("Connected" -ne $currentprovisioningstate)
{
write-Host -Fore "Current Status of Global Reach Connection: $currentprovisioningstate"
Start-Sleep -Seconds 10
$provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.CircuitConnectionStatus}

if("Connected" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Green "Success: AVS Private Cloud $pcname is Connected via Global Reach to $NameOfOnPremExRCircuit"
  
}
#>