$status = Get-AzVirtualNetworkGateway -Name $exrgwname -ResourceGroupName $rgname -ErrorAction Ignore

if ($status.ProvisioningState -notlike "Succeeded")

{

  #Create Gateway Subnet
  $getexpressroutegatewayvnet = Get-AzVirtualNetwork -Name $exrvnetname -ResourceGroupName $rgname 
  Add-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $getexpressroutegatewayvnet -AddressPrefix $gatewaysubnetaddressspace
  Set-AzVirtualNetwork -VirtualNetwork $getexpressroutegatewayvnet 

 #get some info   
  $vnet = Get-AzVirtualNetwork -Name $exrvnetname -ResourceGroupName $rgname
  $vnet
  
##  $vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet
 # $vnet
  
  $subnet = Get-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $vnet
  $subnet
  
  #create public IP
  $pip = New-AzPublicIpAddress -Name $exrgwipname -ResourceGroupName $vnet.ResourceGroupName -Location $vnet.Location -AllocationMethod Dynamic
  $pip
  if ($pip.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of the Public IP Failed"
  Exit}
  
  $ipconf = New-AzVirtualNetworkGatewayIpConfig -Name $exrgwipname -Subnet $subnet -PublicIpAddress $pip
  $ipconf
  
  #create the gateway

  Write-Host -ForegroundColor Yellow "
  Creating a ExpressRoute Gateway ... this could take 30-40 minutes ..."
  $command = New-AzVirtualNetworkGateway -Name $exrgwname -ResourceGroupName $vnet.ResourceGroupName -Location $vnet.Location -IpConfigurations $ipconf -GatewayType Expressroute -GatewaySku Standard
  $command | ConvertTo-Json
}