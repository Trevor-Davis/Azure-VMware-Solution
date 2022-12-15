$testforvnet = Get-AzVirtualNetwork -Name $exrvnetname -ResourceGroupName $rgname -ErrorAction:Ignore

if ($testforvnet.count -eq 1) {
    write-Host -ForegroundColor Blue "
vNet $exrvnetname Is Already Deployed"
  }
  
  if ($testforvnet.count -eq 0) {
  $vnet = @{
    Name = $exrvnetname
    ResourceGroupName = $rgname
    Location = $regionfordeployment
    AddressPrefix = $vnetaddressspace
}

$command = New-AzVirtualNetwork @vnet 
$command

$getexpressroutegatewayvnet = Get-AzVirtualNetwork -Name $exrvnetname -ResourceGroupName $rgname 
Add-AzVirtualNetworkSubnetConfig -Name "Default" -VirtualNetwork $getexpressroutegatewayvnet -AddressPrefix $defaultvnetsubnet
Set-AzVirtualNetwork -VirtualNetwork $getexpressroutegatewayvnet 

}
