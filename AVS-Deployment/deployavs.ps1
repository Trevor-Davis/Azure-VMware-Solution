##################################
#Connect To Azure
##################################
$filename = "ConnectToAzure.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename

##################################
#Register Resource Provider
##################################
$filename = "registeravsresourceprovider.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename

##################################
#Create Resource Group
##################################
$filename = "createresourcegroup.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename 

##################################
#Kickoff Private Cloud Build
##################################
$filename = "kickoffpcbuild.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename 

##################################
#Create vNet
##################################
$filename = "kickoffpcbuild.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename 

<#
#Variables
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


##Anything being done here is because the variable name needs to exist for other scripts being pulled in.
$global:resourcegroupname = $global:rgfordeployment
$global:region = $global:regionfordeployment
$global:VIServerIP = $global:OnPremVIServerIP
#>