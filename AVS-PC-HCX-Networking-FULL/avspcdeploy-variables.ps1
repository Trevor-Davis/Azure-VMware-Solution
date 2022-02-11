$sub = "1178f22f-6ce4-45e3-bd92-ba89930be5be"
$regionfordeployment = "southeastasia"
$RGNewOrExisting = "Existing" #RGforAVSNewOrExisting
$rgfordeployment = "VirtualWorkloads-APAC-AzureCloud" #rgfordeployment
##or
$rgfordeploymentnew = "" #rgfordeploymentnew
$pcname = "AVS1-VirtualWorkloads-APAC-AzureCloud"
$skus = "AV36"
$addressblock = "10.1.0.0/22"
$ExrGatewayForAVS = "ExRGW-VirtualWorkloads-APAC-Hub" ##existingvnetgwname
$SameSubAVSAndExRGW = "Yes" #Same
$OnPremExRCircuitSub = "3988f2d0-8066-42fa-84f2-5d72f80901da" #if ExR and AVS in same sub, then onpremexrcircuitsub is the same as $sub, if different, 
#then take input from form
$ExrGWforAVSResourceGroup = "VirtualWorkloads-APAC-Hub"
$NameOfOnPremExRCircuit = "tnt15-cust-p01-australiaeast-er" 
$ExrForAVSRegion = "southeastasia" 
$RGofOnPremExRCircuit = "Prod_AVS_RG"  
$internet = "Enabled"
$numberofhosts = "3"
