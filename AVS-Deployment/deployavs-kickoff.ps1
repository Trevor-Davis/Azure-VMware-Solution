#Variables
$global:sub = "3988f2d0-8066-42fa-84f2-5d72f80901da" #SubscriptionID
$global:regionfordeployment = "Australia East"
$global:rgname = "VirtualWorkloads-AVSPrivateCloud-RG" #The REsource Group To Deploy AVS, Can be New or Existing
$global:pcname = "VirtualWorkloads-AVSPrivateCloud" #The name of the AVS Private Cloud
$global:avsaddressblock = "192.168.0.0/22" #The /22 Network Block for AVS Infra
$global:skus = "AV36" #The AVS SKU Type to Deploy
$global:numberofhosts = "3" #This should be left at 3
$global:internet = "Enabled" 
$global:exrgwname = "VirtualWorkloads-AVSPrivateCloud-ExRGW" #the exr gw where AVS will connect, if you are connecting to an existing expressroute put the name into this variable, if you are creating a new ExR gateway, put the name in which you want it to be called.
$global:exrvnetname = "VirtualWorkloads-AVSPrivateCloud-vnet" #The vNet where either the ExpressRoute Gateway exists or the vnet where the expressroute gateway will be created.

##################################################################################################
#The following only modify if there is a need to create a new expressroute gateway, 
#if using an existing expressroute gateway do not modify these variables, as they will be ignored
##################################################################################################
$global:vnetaddressspace = "10.0.0.0/16" #the address space to use for the vnet (item above), if the vnet already exists this variable will be ignored.
$global:defaultvnetsubnet = "10.0.1.0/24" #if the vNet where the ExpressRoute Gateway will be created already exists, just ignore this variable, do not modify, it will be ignored.
$global:gatewaysubnetaddressspace = "10.0.1.0/24" #this is the subnet for the expressroute gateway, must be a subnet within the vnet addressspace if you are creating a new expressroute gateway, if you are using an existing expressroute gateway, this variable will be ignored.
$global:gatewaysubnetname = "GatewaySubnet" #DO NOT MODIFY
$global:exrgwipname = "$exrgwname-PIP" #DO NOT MODIFY
##################################################################################################



################################################################
#DO NOT MODIFY
################################################################
$global:folder = "AVS-Deployment" #This is where all the files will be downloaded to which will be used to deploy AVS
$quickeditsettingatstartofscript = Get-ItemProperty -Path "HKCU:\Console" -Name Quickedit
Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit 0
$quickeditsettingatstartofscript.QuickEdit
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
$ProgressPreference = 'SilentlyContinue'

##################################
#Create Directory
##################################

if (Test-Path -Path $env:TEMP\$folder ) {
  Remove-Item $env:TEMP\$folder\*.* -Recurse -Force -ErrorAction:Ignore
} else {
  mkdir $env:TEMP\$folder 
}

##################################
#Start Logging
##################################
Start-Transcript -Path $env:TEMP\$folder\avsdeploy.log -Append


##################################
#Begin
##################################
$filename = "deployavs.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename



<#
#Variables
$global:regionfordeployment = "West US"
$global:pcname = "Prod_Private_Cloud"
$global:skus = "AV36"
$global:avsaddressblock = "192.168.4.0/22"
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