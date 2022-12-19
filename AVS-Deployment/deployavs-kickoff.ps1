#Variables
$global:sub = "3988f2d0-8066-42fa-84f2-5d72f80901da" #SubscriptionID
$global:regionfordeployment = "Australia East"
$global:rgname = "VirtualWorkloads-AVSPrivateCloud-RG" #The REsource Group To Deploy AVS, Can be New or Existing
$global:pcname = "VirtualWorkloads-AVSPrivateCloud" #The name of the AVS Private Cloud
$global:avsaddressblock = "192.168.0.0/22" #The /22 Network Block for AVS Infra
$global:avssku = "AV36" #The AVS SKU Type to Deploy
$global:numberofhosts = "3" #This should be left at 3
$global:internet = "Enabled" 
$global:exrgwname = "VirtualWorkloads-AVSPrivateCloud-ExRGW" #the exr gw where AVS will connect, if you are connecting to an existing expressroute put the name into this variable, if you are creating a new ExR gateway, put the name in which you want it to be called.
$global:exrvnetname = "VirtualWorkloads-AVSPrivateCloud-vnet" #The vNet where either the ExpressRoute Gateway exists or the vnet where the expressroute gateway will be created.
$global:avsexrauthkeyname = "to-ExpressRouteGateway-$exrgwname"
$global:avsexrgwconnectionname = "from-AVSPrivateCloud-$pcname"
$global:nameofonpremexrcircuit = "expressroute"
$global:rgnameonpremexrcircuit = "VirtualWorkloads-AVSPrivateCloud-RG"
$global:nameofavsglobalreachconnection = "to-$nameofonpremexrcircuit"

##################################################################################################
#The following only modify if there is a need to create a new expressroute gateway, 
#if using an existing expressroute gateway do not modify these variables, as they will be ignored
##################################################################################################
$global:vnetaddressspace = "10.0.0.0/16" #the address space to use for the vnet (item above), if the vnet already exists this variable will be ignored.
$global:defaultvnetsubnet = "10.0.1.0/24" #if the vNet where the ExpressRoute Gateway will be created already exists, just ignore this variable, do not modify, it will be ignored.
$global:gatewaysubnetaddressspace = "10.0.2.0/24" #this is the subnet for the expressroute gateway, must be a subnet within the vnet addressspace if you are creating a new expressroute gateway, if you are using an existing expressroute gateway, this variable will be ignored.
$global:gatewaysubnetname = "GatewaySubnet" #DO NOT MODIFY
$global:exrgwipname = "$exrgwname-PIP" #DO NOT MODIFY

#DO NOT MODIFY BELOW THIS LINE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

$quickeditsettingatstartofscript = Get-ItemProperty -Path "HKCU:\Console" -Name Quickedit
Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit 0
$quickeditsettingatstartofscript.QuickEdit
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
$ProgressPreference = 'SilentlyContinue'


#Create Directory
$global:folder = "AVS-Deployment" #This is where all the files will be downloaded to which will be used to deploy AVS
if (Test-Path -Path $env:TEMP\$folder ) {
  Remove-Item $env:TEMP\$folder\*.* -Recurse -Force -ErrorAction:Ignore
} else {
  mkdir $env:TEMP\$folder 
}

#Start Logging
Start-Transcript -Path $env:TEMP\$folder\avsdeploy.log -Append

#Begin
$filename = "deployavs.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename