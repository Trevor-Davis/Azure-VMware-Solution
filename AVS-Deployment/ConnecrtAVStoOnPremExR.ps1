##Generate Auth Key on On-Prem ExR

$status = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $avsrgname -ErrorAction Ignore
if ($status.count -eq 1 -and $status.CircuitConnectionStatus -eq "Connected") {
write-Host -ForegroundColor Blue "
ExpressRoute GlobalReach Connection Established Already, Skipping To Next Step..."
}
else
{
    
$Circuit = Get-AzExpressRouteCircuit -Name $nameofonpremexrcircuit -ResourceGroupName $rgofonpremexrcircuit
$command = Add-AzExpressRouteCircuitAuthorization -Name "for-AVS-Private-Cloud-$pcname" -ExpressRouteCircuit $Circuit
$command = Set-AzExpressRouteCircuit -ExpressRouteCircuit $Circuit
$onpremexrauthkey = $command.Authorizations.AuthorizationKey
$onpremexrid = $command.id

if ($command.count -eq 1){
Write-Host -ForegroundColor Green "
Success: Auth Key Generated for AVS On Express Route $nameofonpremexrcircuit"
}
else {
  
Write-Host -ForegroundColor Green "
On-Prem ExpressRoute Authorization Key Failed to Generate"
Exit
}
}

#Connects to On-Prem Circuit
$command = New-AzVMwareGlobalReachConnection -Name $nameofavsglobalreachconnection -PrivateCloudName $pcname -ResourceGroupName $avsrgname -AuthorizationKey $onpremexrauthkey -PeerExpressRouteResourceId $onpremexrid
  
if ($command.ProvisioningState -notlike "Succeeded"){Write-Host -ForegroundColor Red "
Creation of the AVS Global Reach Connection Failed"
Exit
}

if ($command.ProvisioningState -eq "Succeeded"){Write-Host -ForegroundColor Green "
Success: AVS Private Cloud $pcname is Connected via Global Reach to $nameofonpremexrcircuit"

}