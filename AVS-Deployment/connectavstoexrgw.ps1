##############################################
#Generate Auth Key
##############################################

$test = Get-AzVMWareAuthorization -Name $avsexrauthkeyname -PrivateCloudName $pcname -ResourceGroupName $rgname -SubscriptionId $sub


if ($test.count -eq 1) {
write-Host -ForegroundColor Blue "
$avsexrauthkeyname Auth Key Already Exists ... Skipping to Next Step"   
}
  
if ($test.count -eq 0) {
write-host -foregroundcolor Yellow "
Creating AVS Auth Key $avsexrauthkeyname"
$command = New-AzVMWareAuthorization -Name $avsexrauthkeyname -PrivateCloudName $pcname -ResourceGroupName $rgname -SubscriptionId $sub
$command | ConvertTo-Json

$test = Get-AzVMWareAuthorization -Name $avsexrauthkeyname -PrivateCloudName $pcname -ResourceGroupName $rgname -SubscriptionId $sub
If(test.count -eq 0){
Write-Host -ForegroundColor Red "
AVS Auth Key $avsexrauthkeyname Failed to Create"
Exit
}
else {
  write-Host -ForegroundColor Green "
AVS Auth Key $avsexrauthkeyname  Successfully Created"
  }
}

######################################################################################
# Connect AVS to ExR GW
#######################################################################################

$test = Get-AzVirtualNetworkGatewayConnection -Name $avsexrgwconnectionname -ResourceGroupName $rgname

if ($test.count -eq 1) {
write-Host -ForegroundColor Blue "
$exrgwname Already Connected ... Skipping to Next Step"   
}
  
if ($test.count -eq 0) {
write-host -foregroundcolor Yellow "
Connecting AVS to $ergwname"
$exrgwtouse = Get-AzVirtualNetworkGateway -Name $exrgwname -ResourceGroupName $rgname
$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgname -SubscriptionId $sub
$peerid = $myprivatecloud.CircuitExpressRouteId

$command = New-AzVirtualNetworkGatewayConnection -Name $avsexrauthkeyname -ResourceGroupName $rgname -Location $regionfordeployment -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key
$command | ConvertTo-Json

$test = Get-AzVirtualNetworkGatewayConnection -Name $avsexrgwconnectionname -ResourceGroupName $rgname
If(test.count -eq 0){
Write-Host -ForegroundColor Red "
Connecting AVS to $ergwname Failed"
Exit
}
else {
  write-Host -ForegroundColor Green "
AVS Connected to $ergwname Successfully"
  }
}