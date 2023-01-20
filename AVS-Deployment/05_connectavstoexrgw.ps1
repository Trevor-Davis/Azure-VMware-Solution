#variables
$sub = $global:avssub
$tenant = ""
$authkeyname = $global:avsexrauthkeyname
$pcname = $global:pcname
$rgname = $global:avsrgname
$exrgwname = $global:exrgwname
$exrgwrg = $global:exrgwrg

$global:avsexrgwconnectionname

#DO NOT MODIFY BELOW THIS LINE #################################################

#Azure Login

$filename = "Function-azurelogin.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$filename
. $env:TEMP\$filename

if ($tenanttoconnect -ne "") {
  azurelogin -subtoconnect $sub -tenanttoconnect $tenant
}
else {
  azurelogin -subtoconnect $sub 
}

#Execution

#Generate Auth Key on AVS ExR
azurelogin -subtoconnect $sub

$test = Get-AzVMWareAuthorization -Name $authkeyname -PrivateCloudName $pcname -ResourceGroupName $rgname -SubscriptionId $sub -ErrorAction Ignore

if ($test.count -eq 1) {
write-Host -ForegroundColor Blue "
$authkeyname Auth Key Already Exists"
$avsexrauthkey = $test.Key
   
}

if ($test.count -eq 0) {
write-host -foregroundcolor Yellow "
Creating AVS Auth Key $avsexrauthkeyname"
$command = New-AzVMWareAuthorization -Name $avsexrauthkeyname -PrivateCloudName $pcname -ResourceGroupName $avsrgname -SubscriptionId $avssub
$command | ConvertTo-Json
$avsexrauthkey = $command.Key

$test = Get-AzVMWareAuthorization -Name $authkeyname -PrivateCloudName $pcname -ResourceGroupName $rgname -SubscriptionId $sub -ErrorAction Ignore
If($test.count -eq 0){
Write-Host -ForegroundColor Red "
AVS Auth Key $authkeyname Failed to Create"
Exit
}
else {
write-Host -ForegroundColor Green "
AVS Auth Key $authkeyname  Successfully Created"
  }
}


# Connect AVS to ExR GW
$test = Get-AzVirtualNetworkGatewayConnection -Name $avsexrgwconnectionname -ResourceGroupName $exrgwrg -ErrorAction Ignore

if ($test.count -eq 1) {
write-Host -ForegroundColor Blue "
$pcname Already Connected to $exrgwname"   
}
else {
  write-host -foregroundcolor Yellow "
Connecting $pcname to $exrgwname ExpressRoute Gateway"
  $exrgwtouse = Get-AzVirtualNetworkGateway -Name $exrgwname -ResourceGroupName $exrgwrg
  $myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgname -SubscriptionId $sub
  $peerid = $myprivatecloud.CircuitExpressRouteId
  
  $test = Get-AzVirtualNetworkGatewayConnection -Name $avsexrgwconnectionname -ResourceGroupName $exrgwrg -ErrorAction Ignore
  
  $command = New-AzVirtualNetworkGatewayConnection -Name $avsexrgwconnectionname -ResourceGroupName $exrgwrg -Location $exrgwregion -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $avsexrauthkey
  $command | ConvertTo-Json
  
  $test = Get-AzVirtualNetworkGatewayConnection -Name $avsexrgwconnectionname -ResourceGroupName $exrgwrg -ErrorAction Ignore
  If($test.count -eq 0){
  Write-Host -ForegroundColor Red "
Connecting AVS to $exrgwname Failed"
  Exit
  }
  else {
    write-Host -ForegroundColor Green "
AVS Connected to $exrgwname Successfully"
    }}