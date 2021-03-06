$filename = "azurelogin-function.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" `
-OutFile $env:TEMP\AVSDeploy\$filename

. $env:TEMP\AVSDeploy\$filename


if ($buildhol_ps1 -notmatch "Yes" -and $avsdeploy_ps1 -notmatch "Yes"){
  Write-Host "No"

  $sub = ""
    $vnettodeployrouteserver = ""
    $RouteServerSubnetAddressPrefix = ""
    $ResourceGroupForRouteServer = ""
    $regionforrouteserver = ""
    $RouteServerName =""
}

azurelogin -subtoconnect $sub
$virtualnetworkforsubnet = Get-AzVirtualNetwork -Name $vnettodeployrouteserver

Add-AzVirtualNetworkSubnetConfig -Name 'RouteServerSubnet' -VirtualNetwork $virtualnetworkforsubnet -AddressPrefix $RouteServerSubnetAddressPrefix
$virtualnetworkforsubnet | Set-AzVirtualNetwork

$ip = @{
  Name = 'myRouteServerIP'
  ResourceGroupName = $ResourceGroupForRouteServer
  Location = $regionforrouteserver
  AllocationMethod = 'Static'
  IpAddressVersion = 'Ipv4'
  Sku = 'Standard'
}
$publicIp = New-AzPublicIpAddress @ip

$myvnetforrouteserver = Get-AzVirtualNetwork -Name $vnettodeployrouteserver
$mysubnetforrouteserver = Get-AzVirtualNetworkSubnetConfig -Name "RouteserverSubnet" -VirtualNetwork $myvnetforrouteserver

Write-Host -ForegroundColor Yellow "
Creating RouteServer ... this could take 30-40 minutes ..."

$command = New-AzRouteServer -RouteServerName $RouteServerName -ResourceGroupName $ResourceGroupForRouteServer -Location $regionforrouteserver -hostedsubnet $mysubnetforrouteserver.id -PublicIpAddress $publicIp
$command | ConvertTo-Json
if ($command.ProvisioningState -notlike "Succeeded"){Write-Host -ForegroundColor Red "Creation of Azure RouteServer Failed"
$failed = "Yes"
Exit}

if ($command.ProvisioningState -eq "Succeeded"){
    
Write-Host -ForegroundColor Green "
Azure RouteServer Created Successfully"

Write-Host -ForegroundColor Yellow "
Enabling Branch to Branch Connectivity"}

$command = Update-AzRouteServer -RouteServerName $RouteServerName -ResourceGroupName $ResourceGroupForRouteServer -AllowBranchToBranchTraffic
$command | ConvertTo-Json

Write-Host -ForegroundColor Green "
Success: Azure RouteServer Created and Updated"
