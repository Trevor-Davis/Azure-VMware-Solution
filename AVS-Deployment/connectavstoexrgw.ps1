##############################################
#Generate Auth Key
##############################################

$test = Get-AzVMWareAuthorization -Name $avsexrauthkeyname -PrivateCloudName $pcname -ResourceGroupName $avsrgname -SubscriptionId $avssub -ErrorAction Ignore


if ($test.count -eq 1) {
write-Host -ForegroundColor Blue "
$avsexrauthkeyname Auth Key Already Exists ... Skipping to Next Step"   
}


$avsexrauthkeyname = "testtest"  

if ($test.count -eq 0) {
write-host -foregroundcolor Yellow "
Creating AVS Auth Key $avsexrauthkeyname"
$command = New-AzVMWareAuthorization -Name $avsexrauthkeyname -PrivateCloudName $pcname -ResourceGroupName $avsrgname -SubscriptionId $avssub
$command | ConvertTo-Json

$test = Get-AzVMWareAuthorization -Name $avsexrauthkeyname -PrivateCloudName $pcname -ResourceGroupName $avsrgname -SubscriptionId $avssub -ErrorAction Ignore
If($test.count -eq 0){
Write-Host -ForegroundColor Red "
AVS Auth Key $avsexrauthkeyname Failed to Create"
Exit
}
else {
  write-Host -ForegroundColor Green "
AVS Auth Key $avsexrauthkeyname  Successfully Created"
  }
}

$avsexrauthkey = $command.Key


######################################################################################
# Connect AVS to ExR GW
#######################################################################################

$test = Get-AzVirtualNetworkGatewayConnection -Name $avsexrgwconnectionname -ResourceGroupName $exrgwrg -ErrorAction Ignore

if ($test.count -eq 1) {
write-Host -ForegroundColor Blue "
$exrgwname Already Connected ... Skipping to Next Step"   
}
  
if ($test.count -eq 0) {
write-host -foregroundcolor Yellow "
Connecting AVS to $exrgwname"
$exrgwtouse = Get-AzVirtualNetworkGateway -Name $exrgwname -ResourceGroupName $exrgwrg
$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $avsrgname -SubscriptionId $avssub
$peerid = $myprivatecloud.CircuitExpressRouteId

$command = New-AzVirtualNetworkGatewayConnection -Name $avsexrgwconnectionname -ResourceGroupName $exrgwname -Location $exrgwregion -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $avsexrauthkey
$command | ConvertTo-Json

$test = Get-AzVirtualNetworkGatewayConnection -Name $avsexrgwconnectionname -ResourceGroupName $exrgwname -ErrorAction Ignore
If($test.count -eq 0){
Write-Host -ForegroundColor Red "
Connecting AVS to $ergwname Failed"
Exit
}
else {
  write-Host -ForegroundColor Green "
AVS Connected to $ergwname Successfully"
  }
}