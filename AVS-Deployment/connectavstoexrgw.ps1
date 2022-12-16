 #   $myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgname -SubscriptionId $sub 
#    $peerid = $myprivatecloud.CircuitExpressRouteId

#######################################################################################
# Generate Auth Key
#######################################################################################

$exrauthkey = New-AzVMWareAuthorization -Name $exrgwconnectionname -PrivateCloudName $pcname -ResourceGroupName $rgname -SubscriptionId $sub

if ($exrauthkey.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "
Creation of the AVS ExpressRoute Auth Key Failed"
Exit}

Write-Host -ForegroundColor Green "
AVS ExpressRoute Auth Key Generated"

#######################################################################################
# Connect AVS to ExR GW
#######################################################################################

Write-host -ForegroundColor Yellow "
Connecting AVS Private Cloud $pcname to $exrgwname"
  
$exrgwtouse = Get-AzVirtualNetworkGateway -Name $exrgwname -ResourceGroupName $rgname
$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgname -SubscriptionId $sub
$peerid = $myprivatecloud.CircuitExpressRouteId

$command = New-AzVirtualNetworkGatewayConnection -Name $exrgwconnectionname -ResourceGroupName $rgname -Location $regionfordeployment -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key

if ($command.ProvisioningState -notlike "Succeeded")
{Write-Host -ForegroundColor Red "Creation of the AVS Virtual Network Connection Failed"
Exit
}

Write-host -ForegroundColor Green "
Success: $pcname Private Cloud is Now Connected to to Virtual Network Gateway $exrgwname"