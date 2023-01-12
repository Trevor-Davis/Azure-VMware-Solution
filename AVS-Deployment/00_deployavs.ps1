#Variables
$global:avssub = "1178f22f-6ce4-45e3-bd92-ba89930be5be" #Sub Where to Deploy AVS
$global:regionfordeployment = "Australia East" #The region where AVS should be deployed
$global:avsrgname = "VirtualWorkloads-AVS-PC01" #The REsource Group To Deploy AVS, Can be New or Existing
$global:pcname = "VirtualWorkloads-AVS-PC01" #The name of the AVS Private Cloud
$global:avsaddressblock = "10.0.0.0/22" #The /22 Network Block for AVS Infra
$global:avssku = "AV36" #The AVS SKU Type to Deploy
$global:numberofhosts = "3" #This should be left at 3
$global:internet = "Enabled" 

#Azure Backbone Network Connectivity
#Azure VMware Solution connects to the Azure Backbone via an internal ExpressRoute, to accomodate this an existing ExpressRoute Gateway needs to be identified or one will need to be created.
$global:exrgwneworexisting = "New" # Set to 'New' if you are creating a new ExpressRoute Gateway for AVS, Set to 'Existing' if an existing ExpressRoute Gateway will be used.
$global:exrvnetname = "VirtualWorkloads-AVS-vNet" #The vNet where either the ExpressRoute Gateway exists or the vnet where the expressroute gateway will be created.

#Only Use these variables if you are using an existing ExpressRoute Gateway to connect AVS
If($exrgwneworexisting -eq "Existing"){

  $global:exrgwname = "" #The name of the ExpressRoute Gateway
  $global:exrgwrg = "" #The resource group of the ExpressRoute Gateway
  $global:exrgwregion = "" #the region where the ExpressRoute Gateway is located
  }

#Only Use these variables if there is a need to create a new expressroute gateway to connect AVS 
If($exrgwneworexisting -eq "New"){

  $global:exrgwname = "For-$pcname" #The name of the ExpressRoute Gateway, only modify if you don't want this to be the name.
  $global:exrgwrg = "VirtualWorkloads-AVS-Networking" #The resource group where the ExR Gateway should be deployed
  $global:exrgwregion = "Australia East" #the region where the ExpressRoute Gateway should be deployed.
  $global:gatewaysubnetaddressspace = "10.20.254.0/24" #this is the subnet for the GatewaySubnet subnet which is needed for the ExpressRoute Gateway
  
  }
  

<#
$global:avsvnetrgname = "" #The resource group where the express route is
$global:nameofonpremexrcircuit = "expressroute" #The name of the on-prem expressroute circuit which AVS will connect
$global:rgofonpremexrcircuit = "VirtualWorkloads-AVSPrivateCloud-RG"
#>



#DO NOT MODIFY BELOW THIS LINE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

$quickeditsettingatstartofscript = Get-ItemProperty -Path "HKCU:\Console" -Name Quickedit
Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit 0
$quickeditsettingatstartofscript.QuickEdit
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
$ProgressPreference = 'SilentlyContinue'

#Testing
$testing = 1

#Constants
$global:nameofavsglobalreachconnection = "to-$nameofonpremexrcircuit"
$global:avsexrauthkeyname = "to-ExpressRouteGateway-$exrgwname"
$global:avsexrgwconnectionname = "from-AVSPrivateCloud-$pcname"
$global:gatewaysubnetname = "GatewaySubnet" #DO NOT MODIFY
$global:exrgwipname = "$exrgwname-PIP" #DO NOT MODIFY

#Create Directory
$global:folder = "AVS-Deployment" #This is where all the files will be downloaded to which will be used to deploy AVS
if (Test-Path -Path $env:TEMP\$folder ) {
  Remove-Item $env:TEMP\$folder\*.* -Recurse -Force -ErrorAction:Ignore
} else {
  mkdir $env:TEMP\$folder 
}

#Start Logging
Start-Transcript -Path $env:TEMP\$folder\avsdeploy.log -Append

if ($testing -eq 0) {
#Begin
$filename = "01_deployazurevmwaresolution.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename
}