$sub = "1178f22f-6ce4-45e3-bd92-ba89930be5be"
$RGNewOrExisting = "Existing"
$rgfordeployment = "VirtualWorkloads-APAC-AzureCloud"
$regionfordeployment = "southeastasia"
$pcname = "AVS1-VirtualWorkloads-APAC-AzureCloud"
$addressblock = "10.1.0.0/22"
$skus = "AV36"
$numberofhosts = "3"
$internet = "Enabled"
$ExrGatewayForAVS = "ExRGW-VirtualWorkloads-APAC-Hub"
$ExRGWResourceGroup = "VirtualWorkloads-APAC-Hub"
$ExrGWforAVSResourceGroup = "VirtualWorkloads-APAC-Hub"
$ExrForAVSRegion = "southeastasia"
$OnPremExRCircuitSub = "3988f2d0-8066-42fa-84f2-5d72f80901da"
$NameOfOnPremExRCircuit = "tnt15-cust-p01-australiaeast-er"
$RGofOnPremExRCircuit = "Prod_AVS_RG" 


Select-AzSubscription -SubscriptionId $sub
$privatecloudinfo = Get-AzVMWarePrivateCloud -ResourceGroupName $rgfordeployment -Name $pcname
$avsvcenter = $privatecloudinfo.EndpointVcsa
ping $avsvcenter
$test = Invoke-WebRequest https://www.nova.edu
write-host $test
$test.StatusCode
