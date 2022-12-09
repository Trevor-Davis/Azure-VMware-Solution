$testforvnet = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rgname -ErrorAction:Ignore


if ($testforvnet.count -eq 1) {
    write-Host -ForegroundColor Blue "
vNet $vnetname Is Already Deployed"
  }
  
  if ($testforvnet.count -eq 0) {
  $vnet = @{
    Name = $vnetname
    ResourceGroupName = $rgname
    Location = $regionfordeployment
    AddressPrefix = $vnetaddressspace
}

$command = New-AzVirtualNetwork @vnet 
$command

}
