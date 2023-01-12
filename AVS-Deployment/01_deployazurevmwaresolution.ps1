##################################
#Functions to Load
################################## 
<#
$filename = "Function-azurelogin.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename
#>


$filename = "Function-createreexpressroutegateway.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename

##################################
#Register Resource Provider
##################################
$filename = "registeravsresourceprovider.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename

##################################  
#Create Resource Group (Function)
##################################
azurelogin -subtoconnect $avssub
$test = Get-AzResourceGroup -Name $avsrgname -Location $avsregion

if ($test.count -eq 1){Write-Host -ForegroundColor Blue "
Resource Group $avsrgname Already Exists"
}
if ($test.count -eq 0){
createresourcegroup -resourcegroup $avsrgname -region $avsregion
}

##################################
#Kickoff Private Cloud Build
##################################
$filename = "deployavsprivatecloud.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename 

##################################
#Create ExpressRoute Gateway (Function)
##################################
azurelogin -subtoconnect $exrgwsub
$test = Get-AzVirtualNetworkGateway -ResourceGroupName $exrgwrg -Name $exrgwname

if ($test.count -eq 1){Write-Host -ForegroundColor Blue "
ExpressRoute Gateway $exrgwname Already Exists"
}
if ($test.count -eq 0){
createexrgateway -vnet $exrgwvnet -resourcegroup $exrgwrg -region $exrgwregion -exrgwname $exrgwname
}

##################################
#Connect AVS to ExR GW
##################################
$filename = "connectavstoexrgw.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename 

##################################
#Connect AVS to On-Prem ExR
##################################
$filename = "ConnecrtAVStoOnPremExR.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename 

<#
#Variables
$global:regionfordeployment = "West US"
$global:pcname = "Prod_Private_Cloud"
$global:avssku = "AV36"
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