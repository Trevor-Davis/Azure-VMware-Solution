<#
$global:sub = "@{outputs('Create_SharePoint_Entry')?['body/subfordeployment']}"
$global:regionfordeployment = "@{outputs('Create_SharePoint_Entry')?['body/regionfordeployment']}"
$global:pcname = "@{outputs('Create_SharePoint_Entry')?['body/NameOfAVSPC']}"
$global:skus = "@{outputs('Create_SharePoint_Entry')?['body/SKUType']}"
$global:addressblock = "@{outputs('Create_SharePoint_Entry')?['body/AVSAddressBlock']}"
$global:ExrGatewayForAVS = "@{outputs('Create_SharePoint_Entry')?['body/existingvnetgwname']}" ##this only gets filled in for ExpressRoute connected on-prem sites.
$global:deployhcxyesorno = "@{outputs('Create_SharePoint_Entry')?['body/DeployHCX']}"
$global:ExrGWforAVSResourceGroup = "@{outputs('Create_SharePoint_Entry')?['body/ExrGWforAVSResourceGroup']}"
$global:NameOfOnPremExRCircuit = "@{outputs('Create_SharePoint_Entry')?['body/NameOfOnPremExRCircuit']}" 
$global:ExRGWForAVSRegion = "@{outputs('Create_SharePoint_Entry')?['body/ExRGWForAVSRegion']}"
$global:AzureConnection = "@{outputs('Create_SharePoint_Entry')?['body/AzureConnection']}"

$global:RGofOnPremExRCircuit = "@{outputs('Create_SharePoint_Entry')?['body/RGofOnPremExRCircuit']}"  
$global:internet = "Enabled"
$global:numberofhosts = "3"

$global:RGNewOrExisting = "@{outputs('Create_SharePoint_Entry')?['body/RGForAVSNewOrExisting']}" #RGforAVSNewOrExisting
if("New" -eq $global:RGNewOrExisting)
{
$global:rgfordeployment = "@{outputs('Create_SharePoint_Entry')?['body/rgfordeployment_x002d_New']}"
}
else {
$global:rgfordeployment = "@{outputs('Create_SharePoint_Entry')?['body/rgfordeployment']}" #rgfordeployment
}


$global:SameSubAVSAndExRGW = "@{outputs('Create_SharePoint_Entry')?['body/SameSubAVSAndExRGW']}"
if ("Yes" -eq $global:SameSubAVSAndExRGW) {
$global:vnetgwsub = $sub
}
else {
$global:vnetgwsub = "@{outputs('Create_SharePoint_Entry')?['body/vnetgwsub']}"
}

$global:OnPremExRCircuitSub = "@{outputs('Create_SharePoint_Entry')?['body/OnPremExRCircuitSub']}"
$global:OnPremVIServerIP = "@{outputs('Create_SharePoint_Entry')?['body/OnPremVIServerIP']}"
$global:PSCSameAsvCenterYesOrNo = "@{outputs('Create_SharePoint_Entry')?['body/PSCIPSameAsVcenterYesOrNo']}"
if ($global:PSCSameAsvCenterYesOrNo -eq "Yes" ) {
  $global:PSCIP = $global:OnPremVIServerIP
}
else {
  $global:PSCIP = "@{outputs('Create_SharePoint_Entry')?['body/PSCIP']}"
}
$global:HCXOnPremRoleMapping = "@{outputs('Create_SharePoint_Entry')?['body/HCXOnPremRoleMapping']}"

$global:VpnGwVnetName = "@{outputs('Create_SharePoint_Entry')?['body/VpnGwVnetName']}" #name of the vNet where the current VPN GW Exists.

$global:RouteServerSubnetAddressPrefix = "@{outputs('Create_SharePoint_Entry')?['body/RouteServerSubnetAddressPrefix']}"

$global:OnPremCluster = "@{outputs('Create_SharePoint_Entry')?['body/OnPremCluster']}"

$global:vmotionportgroup =  "@{outputs('Create_SharePoint_Entry')?['body/vmotionportgroup']}"
$global:vmotionprofilegateway = "@{outputs('Create_SharePoint_Entry')?['body/vmotionprofilegateway']}"
$global:vmotionnetworkmask = "@{outputs('Create_SharePoint_Entry')?['body/vmotionnetworkmask']}"
$global:vmotionippool = "@{outputs('Create_SharePoint_Entry')?['body/vmotionippool']}"

$global:managementportgroup = "@{outputs('Create_SharePoint_Entry')?['body/managementportgroup']}"
$global:mgmtprofilegateway = "@{outputs('Create_SharePoint_Entry')?['body/mgmtprofilegateway']}"
$global:mgmtnetworkmask = "@{outputs('Create_SharePoint_Entry')?['body/mgmtnetworkmask']}"
$global:mgmtippool = "@{outputs('Create_SharePoint_Entry')?['body/mgmtippool']}"

$global:VMNetwork = "@{outputs('Create_SharePoint_Entry')?['body/VMNetwork']}"
$global:Datastore = "@{outputs('Create_SharePoint_Entry')?['body/Datastore']}"

$global:HCXManagerVMName = "@{outputs('Create_SharePoint_Entry')?['body/HCXManagerVMName']}"
$global:HCXVMIP = "@{outputs('Create_SharePoint_Entry')?['body/HCXVMIP']}"
$global:HCXVMNetmask = "@{outputs('Create_SharePoint_Entry')?['body/HCXVMNetmask']}"
$global:HCXVMGateway = "@{outputs('Create_SharePoint_Entry')?['body/HCXVMGateway']}"
$global:HCXVMDNS = "@{outputs('Create_SharePoint_Entry')?['body/HCXVMDNS']}"
$global:HCXVMDomain = "@{outputs('Create_SharePoint_Entry')?['body/HCXVMDomain']}"
$global:AVSVMNTP = "@{outputs('Create_SharePoint_Entry')?['body/AVSVMNTP']}"
$global:HCXOnPremLocation = "@{outputs('Create_SharePoint_Entry')?['body/HCXOnPremLocation']}"
$global:hcxVDS = "@{outputs('Create_SharePoint_Entry')?['body/hcxVDS']}"
$global:l2networkextension = "@{outputs('Create_SharePoint_Entry')?['body/NetworkExtension']}"
     
$global:HCXOnPremUserID = "admin"
     $global:mgmtnetworkprofilename = "Management"
     $global:vmotionnetworkprofilename = "vMotion"
     $global:hcxactivationurl = "https://connect.hcx.vmware.com"
     $global:HCXCloudUserID = "cloudadmin@vsphere.local"
     $global:hcxComputeProfileName = "AVS-ComputeProfile"
     $global:hcxServiceMeshName = "AVS-ServiceMesh"
$global:hcxfilename = "VMware-HCX-Connector-4.3.1.0-19373134.ova"


#>


$global:sub = "3988f2d0-8066-42fa-84f2-5d72f80901da"
$global:regionfordeployment = "West US"
$global:pcname = "Prod_Private_Cloud"
$global:skus = "AV36"
$global:addressblock = "192.168.4.0/22"
$global:ExrGatewayForAVS = "THIS WILL NEED TO BEPOPULATED BY SCRIPT" ##this only gets filled in for ExpressRoute connected on-prem sites.
$global:VWanHUBNameWithExRGW = "VirtualWorkloads-vWANHub" ##NEW
$global:deployhcxyesorno = "No"
$global:ExrGWforAVSResourceGroup = "VirtualWorkloads"
$global:NameOfOnPremExRCircuit = "prod_express_route" 
$global:ExRGWForAVSRegion = "westus"
$global:AzureConnection = "ExpressRoute"

$global:RGofOnPremExRCircuit = "Prod_AVS_RG"  
$global:internet = "Enabled"
$global:numberofhosts = "3"

$global:RGNewOrExisting = "New" #RGforAVSNewOrExisting
if("New" -eq $global:RGNewOrExisting)
{
$global:rgfordeployment = "Prod_RG"
}
else {
$global:rgfordeployment = "" #rgfordeployment
}


$global:SameSubAVSAndExRGW = "Yes"
if ("Yes" -eq $global:SameSubAVSAndExRGW) {
$global:vnetgwsub = $sub
}
else {
$global:vnetgwsub = ""
}

$global:OnPremExRCircuitSub = ""
$global:OnPremVIServerIP = ""
$global:PSCSameAsvCenterYesOrNo = ""
if ($global:PSCSameAsvCenterYesOrNo -eq "Yes" ) {
  $global:PSCIP = $global:OnPremVIServerIP
}
else {
  $global:PSCIP = ""
}
$global:HCXOnPremRoleMapping = ""

$global:VpnGwVnetName = "" #name of the vNet where the current VPN GW Exists.

$global:RouteServerSubnetAddressPrefix = ""

$global:OnPremCluster = ""

$global:vmotionportgroup =  ""
$global:vmotionprofilegateway = ""
$global:vmotionnetworkmask = ""
$global:vmotionippool = ""

$global:managementportgroup = ""
$global:mgmtprofilegateway = ""
$global:mgmtnetworkmask = ""
$global:mgmtippool = ""

$global:VMNetwork = ""
$global:Datastore = ""

$global:HCXManagerVMName = ""
$global:HCXVMIP = ""
$global:HCXVMNetmask = ""
$global:HCXVMGateway = ""
$global:HCXVMDNS = ""
$global:HCXVMDomain = ""
$global:AVSVMNTP = ""
$global:HCXOnPremLocation = ""
$global:hcxVDS = ""
$global:l2networkextension = ""
     
$global:HCXOnPremUserID = "admin"
     $global:mgmtnetworkprofilename = "Management"
     $global:vmotionnetworkprofilename = "vMotion"
     $global:hcxactivationurl = "https://connect.hcx.vmware.com"
     $global:HCXCloudUserID = "cloudadmin@vsphere.local"
     $global:hcxComputeProfileName = "AVS-ComputeProfile"
     $global:hcxServiceMeshName = "AVS-ServiceMesh"
$global:hcxfilename = "VMware-HCX-Connector-4.3.1.0-19373134.ova"

