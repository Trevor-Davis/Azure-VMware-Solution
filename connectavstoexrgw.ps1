$filename = "azurelogin-function.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" `
-OutFile $env:TEMP\AVSDeploy\$filename
Clear-Host
. $env:TEMP\AVSDeploy\$filename

if ($buildhol_ps1 -notmatch "Yes" -and $avsdeploy_ps1 -notmatch "Yes"){
  Write-Host "No"
  $exrgwsub ="" #this is the sub where the ExR GW is.
  $pcsub = "" #sub of the private cloud
  $exrgwname = ""
  $exrgwrg = ""
  $exrgwregion = ""
  $pcname = ""
  $pcresourcegroup = ""
  $exrauthkeyname = ""
  $exrgwconnectionname = ""
}

  azurelogin -subtoconnect $exrgwsub
  
$exrgwtouse = Get-AzVirtualNetworkGateway -Name $exrgwname -ResourceGroupName $exrgwrg
$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $pcresourcegroup -SubscriptionId $pcsub
$peerid = $myprivatecloud.CircuitExpressRouteId
$exrauthkey = Get-AzVMWareAuthorization -Name $exrauthkeyname -PrivateCloudName $pcname -ResourceGroupName $pcresourcegroup -SubscriptionId $pcsub -ErrorAction Ignore

$command = New-AzVirtualNetworkGatewayConnection -Name $exrgwconnectionname -ResourceGroupName $exrgwrg -Location $exrgwregion -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key
if ($command.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of the AVS Virtual Network Connection Failed"
Exit
$failed = "Yes"
}

Write-host -ForegroundColor Green "
Success: $pcname Private Cloud is Now Connected to to Virtual Network Gateway $exrgwname"