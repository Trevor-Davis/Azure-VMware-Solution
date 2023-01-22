#variables
$pcname = $global:pcname
$rgname = $global:avsrgname
$OnPremExpressRouteCircuitSub = $global:OnPremExpressRouteCircuitSub
$nameofonpremexrcircuit = $global:nameofonpremexrcircuit
$rgofonpremexrcircuit = $global:rgofonpremexrcircuit 
$sub = $global:avssub
$nameofavsglobalreachconnection = $global:nameofavsglobalreachconnection


#DO NOT MODIFY BELOW THIS LINE #################################################
Update-AzConfig -DisplayBreakingChangeWarning $false
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

$status = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgname -ErrorAction Ignore
if ($status.count -eq 1 -and $status.CircuitConnectionStatus -eq "Connected") {
write-Host -ForegroundColor Blue "
AVS On-Premises Connection Already Established."
Exit
}
else
{

azurelogin -subtoconnect $OnPremExpressRouteCircuitSub

$Circuit = Get-AzExpressRouteCircuit -Name $nameofonpremexrcircuit -ResourceGroupName $rgofonpremexrcircuit

$test = Get-AzExpressRouteCircuitAuthorization -Name "for-AVS-Private-Cloud-$pcname" -ExpressRouteCircuit $Circuit -ErrorAction:Ignore

if ($test.ProvisioningState -ne "Succeeded") {
    $command = Add-AzExpressRouteCircuitAuthorization -Name "for-AVS-Private-Cloud-$pcname" -ExpressRouteCircuit $Circuit
    $command = Set-AzExpressRouteCircuit -ExpressRouteCircuit $Circuit
    $onpremexrauthkey = $command.Authorizations.AuthorizationKey
    $onpremexrid = $command.id
    if ($command.count -eq 1){
        Write-Host -ForegroundColor Green "
Auth Key Generated for AVS On Express Route $nameofonpremexrcircuit"
        }
        else {
          
        Write-Host -ForegroundColor Red "
On-Prem ExpressRoute Authorization Key Failed to Generate"
        Exit
        }
}
else {
    Write-Host -ForegroundColor Blue "
Auth Key Already Exists for AVS On Express Route $nameofonpremexrcircuit"
    $onpremexrauthkey = $test.AuthorizationKey
    $command = Set-AzExpressRouteCircuit -ExpressRouteCircuit $Circuit
    $onpremexrid = $command.id
}



}

#Connects to On-Prem Circuit
azurelogin -subtoconnect $avssub

$command = New-AzVMwareGlobalReachConnection -Name $nameofavsglobalreachconnection -PrivateCloudName $pcname -ResourceGroupName $rgname -AuthorizationKey $onpremexrauthkey -PeerExpressRouteResourceId $onpremexrid
  
if ($command.ProvisioningState -notlike "Succeeded"){Write-Host -ForegroundColor Red "
Creation of the AVS Global Reach Connection Failed"
Exit
}

if ($command.ProvisioningState -eq "Succeeded"){Write-Host -ForegroundColor Green "
AVS Private Cloud $pcname is Connected via Global Reach to $nameofonpremexrcircuit"

}