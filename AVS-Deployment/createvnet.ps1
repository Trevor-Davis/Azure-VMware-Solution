$test = Get-AzVirtualNetwork -Name $exrvnetname -ResourceGroupName $rgname -ErrorAction:Ignore

if ($test.count -eq 1) {
write-Host -ForegroundColor Blue "
$exrvnetname Already Exists ... Skipping to Next Step"   
}
  
if ($test.count -eq 0) {
write-host -foregroundcolor Yellow "
Creating Virtual Network $exrvnetname"
{
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

$test = Get-AzVirtualNetwork -Name $exrvnetname -ResourceGroupName $rgname -ErrorAction:Ignore
If(test.count -eq 0){
Write-Host -ForegroundColor Red "
Virtual Network $exrvnetname Failed to Create"
Exit
}
else {
  write-Host -ForegroundColor Green "
Virtual Network $exrvnetname Successfully Created"
  }
}

