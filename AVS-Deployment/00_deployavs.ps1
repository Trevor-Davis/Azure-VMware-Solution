#select excel file you want to read
#$mypath = $MyInvocation.MyCommand.Path 
#$mypath = split-path $mypath -Parent

#$file = "$mypath\avssimplifieddeployment.xlsx"
$file = "C:\Users\tredavis\OneDrive - Microsoft\GitHub\Azure VMware Solution\AVS-Deployment\avssimplifieddeployment.xlsx"

$sheetName = "AVSSimplifiedDeployment-Inputs"

#create new excel COM object
$excel = New-Object -com Excel.Application

#open excel file
$wb = $excel.workbooks.open($file)

#select excel sheet to read data
$sheet = $wb.Worksheets.Item($sheetname)

$global:avssub = $sheet.Cells.Item(5,2).Text #Sub Where to Deploy AVS
$global:regionfordeployment = $sheet.Cells.Item(6,2).Text #The region where AVS should be deployed
$global:avsrgname = $sheet.Cells.Item(7,2).Text #The REsource Group To Deploy AVS, Can be New or Existing
$global:pcname = $sheet.Cells.Item(8,2).Text #The name of the AVS Private Cloud
$global:avsaddressblock = $sheet.Cells.Item(9,2).Text 
$global:avssku = $sheet.Cells.Item(10,2).Text 
$global:OnPremConnectivity = $sheet.Cells.Item(22,2).Text  #Options are ExpressRoute, VPN, None
if ($global:OnPremConnectivity -eq "VPN/SD-WAN") {$global:OnPremConnectivity = "VPN"}
if ($global:OnPremConnectivity -eq "It dosen't") {$global:OnPremConnectivity = "None"}

#Azure Backbone Network Connectivity
$global:exrgwneworexisting = $sheet.Cells.Item(13,2).Text  # Set to 'New' if you are creating a new ExpressRoute Gateway for AVS, Set to 'Existing' if an existing ExpressRoute Gateway will be used.

#On Prem Connectivity - Only Modify these variables if you are connecting AVS to on-prem via an on-prem ExpressRoute.
$global:OnPremExpressRouteCircuitSub = $sheet.Cells.Item(25,2).Text 
$global:nameofonpremexrcircuit = $sheet.Cells.Item(26,2).Text 
$global:rgofonpremexrcircuit = $sheet.Cells.Item(27,2).Text 

#Only Use these variables if you are using an EXISTING ExpressRoute Gateway to connect AVS
If($exrgwneworexisting -eq "Existing"){

  $global:exrgwsub = $sheet.Cells.Item(14,2).Text  #This could be the same or different Sub ID than the private cloud.
  $global:exrvnetname = $sheet.Cells.Item(15,2).Text  #The name of the vNet where the expressroute gateway already exists.
  $global:exrgwname = $sheet.Cells.Item(16,2).Text  #The name of the ExpressRoute Gateway
  $global:exrgwrg = $sheet.Cells.Item(18,2).Text  #The resource group of the ExpressRoute Gateway
  $global:exrgwregion = $sheet.Cells.Item(17,2).Text  #the region where the ExpressRoute Gateway is located
  }

#Only Use these variables if there is a need to create a NEW expressroute gateway to connect AVS 
If($exrgwneworexisting -eq "New"){

  $global:exrgwsub = $sheet.Cells.Item(14,2).Text  #This could be the same or different Sub ID than the private cloud.
  $global:exrvnetname = $sheet.Cells.Item(15,2).Text  #The name of the vNet where the expressroute gateway already exists.
  $global:exrgwname = $sheet.Cells.Item(16,2).Text  #The name of the ExpressRoute Gateway
  $global:exrgwrg = $sheet.Cells.Item(18,2).Text  #The resource group of the ExpressRoute Gateway
  $global:exrgwregion = $sheet.Cells.Item(17,2).Text  #the region where the ExpressRoute Gateway is located
  $global:gatewaysubnetaddressspace = $sheet.Cells.Item(19,2).Text #this is the subnet for the GatewaySubnet subnet which is needed for the ExpressRoute Gateway
  }


  $global:numberofhosts = "3" #This should be left at 3
  $global:internet = "Enabled" 
  
$excel.Quit()

Stop-Process -Name EXCEL -Force


<#
#################################
#Variables
#################################

$global:avssub = "1178f22f-6ce4-45e3-bd92-ba89930be5be" #Sub Where to Deploy AVS
$global:regionfordeployment = "Australia East" #The region where AVS should be deployed
$global:avsrgname = "VirtualWorkloads-AVS-PC03" #The REsource Group To Deploy AVS, Can be New or Existing
$global:pcname = "VirtualWorkloads-AVS-PC03" #The name of the AVS Private Cloud
$global:avsaddressblock = "10.0.8.0/22" #The /22 Network Block for AVS Infra
$global:avssku = "AV36" #The AVS SKU Type to Deploy
$global:numberofhosts = "3" #This should be left at 3
$global:internet = "Enabled" 
$global:OnPremConnectivity = "None" #Options are ExpressRoute, VPN, None

<#$global:networkCIDRForApplianceVM = "192.168.200.1/28" #input the network gateway in this format, this is the network which will be created 10.1.1.1/24
$global:applianceControlPlaneIpAddress = "192.168.200.2"
$global:k8sNodeIPPoolStart = "192.168.200.20"
$global:k8sNodeIPPoolEnd = "192.168.200.30"
$global:gatewayIPAddress = "192.168.200.1"
$global:networkForApplianceVM = "ARCforAVS-Segment" #this is NSX segment name which will be created for ARC


#Azure Backbone Network Connectivity
$global:exrgwneworexisting = "Existing" # Set to 'New' if you are creating a new ExpressRoute Gateway for AVS, Set to 'Existing' if an existing ExpressRoute Gateway will be used.

#On Prem Connectivity - Only Modify these variables if you are connecting AVS to on-prem via an on-prem ExpressRoute.
$global:OnPremExpressRouteCircuitSub = "1178f22f-6ce4-45e3-bd92-ba89930be5be"
$global:nameofonpremexrcircuit = "VirtualWorkloads-ExpressRoute-Central-US" #The name of the on-premises ExpressRoute Circuit.
$global:rgofonpremexrcircuit = "VirtualWorkloads-AVS-Networking-Central-US" #The resource group where the on-prem expressroute circuit exists.

#Only Use these variables if you are using an EXISTING ExpressRoute Gateway to connect AVS
If($exrgwneworexisting -eq "Existing"){

  $global:exrgwsub = "1178f22f-6ce4-45e3-bd92-ba89930be5be" #This could be the same or different Sub ID than the private cloud.
  $global:exrvnetname = "VirtualWorkloads-AVS-vNet-Australia-East" #The name of the vNet where the expressroute gateway already exists.
  $global:exrgwname = "For-VirtualWorkloads-AVS-PC01" #The name of the ExpressRoute Gateway
  $global:exrgwrg = "VirtualWorkloads-AVS-Networking-Australia-East" #The resource group of the ExpressRoute Gateway
  $global:exrgwregion = "Australia East" #the region where the ExpressRoute Gateway is located
  }

#Only Use these variables if there is a need to create a NEW expressroute gateway to connect AVS 
If($exrgwneworexisting -eq "New"){

  $global:exrgwsub = "Same" #This could be the same or different Sub ID than the private cloud.
  $global:exrvnetname = "VirtualWorkloads-AVS-vNet-Australia-East" #The name of the vNet where the expressroute gateway will be created.
  $global:exrgwname = "For-$pcname" #The name of the ExpressRoute Gateway, only modify if you don't want this to be the name.
  $global:exrgwrg = "VirtualWorkloads-AVS-Networking-Australia-East" #The resource group where the ExR Gateway should be deployed
  $global:exrgwregion = "Australia East" #the region where the ExpressRoute Gateway should be deployed.
  $global:gatewaysubnetaddressspace = "10.20.1.0/24" #this is the subnet for the GatewaySubnet subnet which is needed for the ExpressRoute Gateway
  
  }

#>


#DO NOT MODIFY BELOW THIS LINE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ProgressPreference = 'SilentlyContinue'
#$ErrorActionPreference = 'SilentlyContinue'

#ID Path where this script is running
$global:myjsonpath = $MyInvocation.MyCommand.Path 
$global:myjsonpath = split-path $myjsonpath -Parent
$global:myjsonpath = $myjsonpath+"\config_avs.json"


#Variables Do Not Modify
$testing = 0
$global:nameofavsglobalreachconnection = "to-$nameofonpremexrcircuit"
$global:avsexrauthkeyname = "to-ExpressRouteGateway-$exrgwname"
$global:avsexrgwconnectionname = "from-AVSPrivateCloud-$pcname"
$global:gatewaysubnetname = "GatewaySubnet" #DO NOT MODIFY
$global:exrgwipname = "$exrgwname-PIP" #DO NOT MODIFY
$global:folderforstaging = "AVS-Deployment" #DO NOT MODIFY
$global:logfilename = "avs-deploy"

#Create Staging Directory
$test = Test-Path -Path $env:TEMP\$folderforstaging
    
if ($test -eq "True"){
Write-Host -ForegroundColor Blue "Folder $env:TEMP\$folderforstaging Already Exists"}

else {

mkdir $env:TEMP\$folderforstaging
}

#Start Logging
Start-Transcript -Path $env:TEMP\$folderforstaging\$logfilename".log" -Append

#Execution

Clear-Host
Write-Host -ForegroundColor Magenta "Deploying Private Cloud $pcname"

##Register Resource Provider
Write-Host -ForegroundColor Yellow "Registering Resource Provider"
$filename = "01_RegisterAVSResourceProvider.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folderforstaging\$filename
. $env:TEMP\$folderforstaging\$filename

#Create Resource Group
Write-Host -ForegroundColor Yellow "Creating Resource Group"
$filename = "02_CreateResourceGroup.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folderforstaging\$filename
. $env:TEMP\$folderforstaging\$filename

#Deploy Private Cloud
Write-Host -ForegroundColor Yellow "Deploying Private Cloud"
$filename = "03_deployavsprivatecloud.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folderforstaging\$filename
. $env:TEMP\$folderforstaging\$filename 

#Create ExpressRoute Gateway
Write-Host -ForegroundColor Yellow "Creating ExpressRoute Gateway"
$filename = "04_createexpressroutegateway.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folderforstaging\$filename
. $env:TEMP\$folderforstaging\$filename 

#Connect AVS to ExR GW
Write-Host -ForegroundColor Yellow "Connect AVS to ExpressRoute Gateway"
$filename = "05_connectavstoexrgw.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folderforstaging\$filename
. $env:TEMP\$folderforstaging\$filename 

#Connect AVS to On-Prem ExR
if ($OnPremConnectivity -eq "ExpressRoute") {
  Write-Host -ForegroundColor Yellow "Connecting AVS to On-Prem ExpressRoute"
  $filename = "06_ConnecrtAVStoOnPremExR.ps1"
  write-host "Downloading" $filename
  Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folderforstaging\$filename
  . $env:TEMP\$folderforstaging\$filename 
}
<#
#Deploy ARC for AVS
Write-Host -ForegroundColor Yellow "Connect AVS to ExpressRoute Gateway"
$filename = "07_deployarcforavs.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folderforstaging\$filename
. $env:TEMP\$folderforstaging\$filename 
#>