$deployvariablesvariables = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/avspcdeploy-variables.ps1
Invoke-Expression $($deployvariablesvariables.Content)

$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment
$peerid = $myprivatecloud.CircuitExpressRouteId
Write-Host -ForegroundColor Yellow "
Generating AVS ExpressRoute Auth Key..."

$exrauthkey = New-AzVMWareAuthorization -Name "Connection-To-$ExrGatewayForAVS" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment 
if ($exrauthkey.ProvisioningState -eq "Succeeded" ) {
    Write-Host -ForegroundColor Green "
AVS ExpressRoute Auth Key Generated"
    }
    if ($exrauthkey.ProvisioningState -ne "Succeeded" ) {
        Write-Host -ForegroundColor Red "
AVS ExpressRoute Auth Key Generation Failed"
        Exit
        }

Write-Host -ForegroundColor Yellow "
Connecting the $pcname Private Cloud to Virtual Network Gateway $ExrGatewayForAVS ... "

$exrgwtouse = Get-AzVirtualNetworkGateway -ResourceGroupName $ExRGWResourceGroup -Name $ExrGatewayForAVS
New-AzVirtualNetworkGatewayConnection -Name "From--$pcname" -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExrForAVSRegion -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key 
 
Write-host -ForegroundColor Green "
Success: $pcname Private Cloud is Now Connected to to Virtual Network Gateway $ExrGatewayForAVS
"