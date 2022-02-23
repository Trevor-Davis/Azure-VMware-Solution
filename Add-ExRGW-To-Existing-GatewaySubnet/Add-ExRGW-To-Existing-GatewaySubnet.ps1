$sub = "Contoso Azure VMware Solution" #sub where the existing VPN GW Exists.
$ExrGWforAVSResourceGroup = "VPN" #RG where the existing VPN GW exists.
$ExRGWForAVSRegion = "Australia East" #location of the vNet which houses the vNet GW
$GWName = "ExRGWforAVS" #the new ExR GW name.
$GWIPName = "ExRGWforAVS-IP" #name of the public IP for ExR GW
$GWIPconfName = "gwipconf" #
$VNetName = "vNet-VPN-APAC-Hub-vnet" #name of the vNet where the current VPN GW Exists.
$exrgwtouse = $GWName
$peerid ="/subscriptions/be8569eb-b087-4090-a1e2-ac12df4818d8/resourceGroups/tnt17-cust-p01-southeastasia/providers/Microsoft.Network/expressRouteCircuits/tnt17-cust-p01-southeastasia-er"
$exrauthkey = "566c3b75-662b-4c28-9ae5-03cc76bfea14" ###CHANGE THIS BELOW BACK TO $exrauthkey.key

Connect-AzAccount -Subscription $sub

$vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ExrGWforAVSResourceGroup
$vnet

$vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet

$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet

$pip = New-AzPublicIpAddress -Name $GWIPName  -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExRGWForAVSRegion -AllocationMethod Dynamic

$ipconf = New-AzVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip

New-AzVirtualNetworkGateway -Name $GWName -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExRGWForAVSRegion -IpConfigurations $ipconf -GatewayType Expressroute -GatewaySku Standard


New-AzVirtualNetworkGatewayConnection -Name "From--AVS1" -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExRGWForAVSRegion -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey
