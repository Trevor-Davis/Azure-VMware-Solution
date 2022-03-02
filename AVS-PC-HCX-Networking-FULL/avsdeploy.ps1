$quickeditsettingatstartofscript = Get-ItemProperty -Path "HKCU:\Console" -Name Quickedit
Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit 0
$quickeditsettingatstartofscript.QuickEdit
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

Start-Transcript -Path $env:TEMP\AVSDeploy\avsdeploy.log -Append
. $env:TEMP\AVSDeploy\variables.ps1


#azure login function
function azurelogin {

  param (
      $subtoconnect
  )
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"

$sublist = @()
  $sublist = Get-AzSubscription
  $checksub = $sublist -match $sub
  If ($checksub.Count -eq 1) {
Set-AzContext -Subscription $subtoconnect
  }
  else {
    Connect-AzAccount -Subscription $subtoconnect
    Set-AzContext -Subscription $subtoconnect
  }

$ErrorActionPreference = "Continue"
$WarningPreference = "Continue"

}

#######################################################################################
#Testing Stuff -- DO NOT MODIFY
#######################################################################################

$global:internaltest="No" #DO NOT MODIFY

if ("Yes" -eq $global:internaltest){
$global:InternalAuthKey = "89193c55-xxxx-4b76-bf2f-05b92a1534ef"
$global:InternalPeerURI = "/subscriptions/52d4e37e-xxxx-4016-98de-fe023475b435/resourceGroups/tnt15-xxxx-p01-australiaeast/providers/Microsoft.Network/expressRouteCircuits/tnt15-cust-p01-australiaeast-er"
$global:OnPremVIServerUsername = "administrator@vsphere.local"
$global:OnPremVIServerPassword = 'xxx'
}

#######################################################################################
# Create Temp Storage Location
#######################################################################################
Clear-Host

#######################################################################################
# Check for Installs
#######################################################################################
#PowerShell 7

Write-Host -ForegroundColor Yellow "The following are required for this script to run properly.
- PowerShell 7.x
- Azure Powershell Modules
- VMware PowerCLI Modules
- Azure CLI"
write-host -foregroundcolor white -nonewline "If these packages aren't already installed would you like this script to install them? (Y/N): "
$installpackages = Read-Host

if ($installpackages -eq "N") {
write-Host -foregroundcolor red "This script requires these modules, if you do not install them the script will not properly run.  Please install the latest versions of all these modules offline and re-run this script."
Exit
}
else {
  
#powershell
if ($PSVersionTable.PSVersion.Major -lt 7){
$PSVersion = $PSVersionTable.PSVersion.Major
Write-Host -ForegroundColor Yellow "
Your Powershell Version Is $PSVersion ... Upgrading to PowerShell 7"
  
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  $PowerShellDownloadURL = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi"
  $PowerShellDownloadFileName = "PowerShell-7.2.1-win-x64.msi"
  Invoke-WebRequest -Uri $PowerShellDownloadURL -OutFile $env:TEMP\AVSDeploy\$PowerShellDownloadFileName
  Start-Process -wait "$env:TEMP\AVSDeploy\$PowerShellDownloadFileName"
  Clear-Host
  Write-Host -ForegroundColor Green "
Success: PowerShell Upgraded"
  Write-Host -ForegroundColor Red "
Please re-run the script from the PowerShell 7 command window"
  Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit $quickeditsettingatstartofscript.QuickEdit
  Exit
}

#Az and Az.VMware Powershell Modules
<#
$vmwareazcheck = Find-Module -Name Az
if ($vmwareazcheck.Name -ne "Az") {
  Write-Host -NoNewline -ForegroundColor Yellow "The AZ and the AZ.VMware Powershell Modules Are NOT Installed, Would You Like To Install Those Now? (Y/N): "
  $AZModuleInstall = Read-Host 
  
  if ($AZModuleInstall -eq "y"){
  #>
  Clear-Host
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Write-Host -ForegroundColor Yellow "Installing/Updating Azure Powershell Modules ..."  
  Install-Module -Name Az -Repository PSGallery -Force
  Write-Host -ForegroundColor Yellow "Az Powershell Module Installed/Updated"
  Install-Module -Name Az.VMware -Repository PSGallery -Force
  Write-Host -ForegroundColor Yellow "Az.VMware Powershell Module Installed/Updated"
start-sleep 5
  Clear-Host

  Write-Host -ForegroundColor Green "
Success: Azure Powershell Modules Installed"

#VMware PowerCLI Modules
$vmwarepowerclicheck = Find-Module -Name VMware.PowerCLI

if ($vmwarepowerclicheck.Name -ne "VMware.PowerCLI") {

    
      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
      Write-Host -ForegroundColor Yellow "Downloading and Installing VMware PowerCLI Modules ..."
    Install-Module -Name VMware.PowerCLI -Force
    Install-Module -Name VMware.VimAutomation.Hcx -Force
Clear-Host

    Write-Host -ForegroundColor Green "
    Success: VMware PowerCLI Modules Installed"

}

$vmwarepowerclihcxcheck = Find-Module -Name VMware.VimAutomation.Hcx
if ($vmwarepowerclihcxcheck.Name -ne "VMware.VimAutomation.Hcx") {
    
      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
      Write-Host -ForegroundColor Yellow "Downloading and Installing VMware HCX PowerCLI Module ..."
    Install-Module -Name VMware.VimAutomation.Hcx -Force
Clear-Host

    Write-Host -ForegroundColor Green "
    Success: VMware HCX PowerCLI Modules Installed"

}
  
#Azure CLI

  $programlist = @()
  $programlist += Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | ForEach-Object {(($_.DisplayName))}  
  $programlist  += Get-ItemProperty 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | ForEach-Object {(($_.DisplayName))}  
  $checkazurecli = $programlist -match 'Microsoft Azure CLI'
  If ($checkazurecli.Count -eq 0) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    $azureCLIDownloadURL = "https://aka.ms/installazurecliwindows"
    $azureCLIDownloadFileName = "AzureCLI.msi"
    Invoke-WebRequest -Uri $azureCLIDownloadURL -OutFile $env:TEMP\AVSDeploy\$azureCLIDownloadFileName 
    Start-Process -wait "$env:TEMP\AVSDeploy\$azureCLIDownloadFileName"
    Clear-Host
    Write-Host -ForegroundColor Green "
    Success: Azure CLI Installed"
    Write-Host -ForegroundColor Red "You will need to re-start the Powershell session and re-run the script .... Press Any Key To Continue"
    Read-Host
    stop-process $PID
  }

  
}

#######################################################################################
# Connect To Azure and Validate Sub Is Ready For AVS
#######################################################################################
Clear-Host
write-host -ForegroundColor Yellow "
Connecting to your Azure Subscription $sub"

azurelogin -subtoconnect $sub

write-host -ForegroundColor Green "
Azure Login Successful"
Write-Host -ForegroundColor Yellow  "
Validating Subscription Readiness ..." 
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
$quota = Test-AzVMWareLocationQuotaAvailability -Location $regionfordeployment -SubscriptionId $sub
$ErrorActionPreference = "Continue"
$WarningPreference = "Continue"
if ("Enabled" -eq $quota.Enabled)
{

Write-Host -ForegroundColor Green "
Success: Quota is Enabled on Subscription"    

Register-AzResourceProvider -ProviderNamespace Microsoft.AVS

Write-Host -ForegroundColor Green "
Success: Resource Provider Enabled"    

}

Else

{
Write-Host -ForegroundColor Red "
Subscription $sub Does NOT Have Quota for Azure VMware Solution, please visit the following site for guidance on how to get this service enabled for your subscription."

Write-Host -ForegroundColor White "
https://docs.microsoft.com/en-us/azure/azure-vmware/enable-azure-vmware-solution
"

Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit $quickeditsettingatstartofscript.QuickEdit
Exit

}

#######################################################################################
# Define The Resource Group For AVS Deploy
#######################################################################################

if ( "Existing" -eq $RGNewOrExisting )
{
    write-host -foregroundcolor Yellow "
AVS Private Cloud Resource Group is $rgfordeployment"
}

if ( "New" -eq $RGNewOrExisting){
    New-AzResourceGroup -Name $rgfordeployment -Location $regionfordeployment

    write-host -foregroundcolor Green "
Success: AVS Private Cloud Resource Group $rgfordeployment Created"   

}

#######################################################################################
# Kickoff Private Cloud Deployment
#######################################################################################

Write-Host -ForegroundColor Green "
Success: The Azure VMware Solution Private Cloud Deployment Has Begun"
Write-Host -ForegroundColor White "
Deployment Status Will Begin To Show Shortly"

New-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub -NetworkBlock $addressblock -Sku $skus -Location $regionfordeployment -managementclustersize $numberofhosts -Internet $internet -NoWait -AcceptEULA

Write-Host -foregroundcolor Blue "
The Azure VMware Solution Private Cloud $pcname deployment is underway and will take approximately 4 hours."
Write-Host -foregroundcolor Yellow "
The status of the deployment will begin to update in 5 minutes."

Start-Sleep -Seconds 300
Clear-Host

$provisioningstate = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"


while ("Succeeded" -ne $currentprovisioningstate)
{
$timeStamp = Get-Date -Format "hh:mm"
write-host -foregroundcolor yellow "$timestamp - Current Status: $currentprovisioningstate - Next Update In 10 Minutes"
Start-Sleep -Seconds 600
$provisioningstate = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
}

if("Succeeded" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Green "$timestamp - Azure VMware Solution Private Cloud $pcname is successfully deployed"
  
}

if("Failed" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Red "$timestamp - Current Status: $currentprovisioningstate

  There appears to be a problem with the deployment of Azure VMware Solution Private Cloud $pcname in subscription $sub "
  Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit $quickeditsettingatstartofscript.QuickEdit

  Exit

}

#######################################################################################
# Connect AVS To vNet w/ VPN GW from On-Prem AND Create Route Server
#######################################################################################

azurelogin -subtoconnect $sub


if ("Site-to-Site VPN" -eq $AzureConnection) {
  

#connect AVS ExR
$ExrGatewayForAVS = "ExRGWfor-$pcname" #the new ExR GW name.
$GWIPName = "ExRGWfor-$pcname-IP" #name of the public IP for ExR GW
$GWIPconfName = "gwipconf" #
$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub
$peerid = $myprivatecloud.CircuitExpressRouteId


azurelogin -subtoconnect $vnetgwsub


$vnet = Get-AzVirtualNetwork -Name $VpnGwVnetName -ResourceGroupName $ExrGWforAVSResourceGroup
$vnet

$vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet
$vnet

$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet
$subnet

$pip = New-AzPublicIpAddress -Name $GWIPName  -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExRGWForAVSRegion -AllocationMethod Dynamic
$pip

$ipconf = New-AzVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip
$ipconf

Write-Host -ForegroundColor Yellow "
Creating a ExpressRoute Gateway for AVS ... this could take 30-40 minutes ..."

$command = New-AzVirtualNetworkGateway -Name $ExrGatewayForAVS -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExRGWForAVSRegion -IpConfigurations $ipconf -GatewayType Expressroute -GatewaySku Standard -NoWait
$command | ConvertTo-Json

############################################
while ("Succeeded" -ne $currentprovisioningstate)
{
$timeStamp = Get-Date -Format "hh:mm"
Start-Sleep -Seconds 300
"$timestamp - Current Status: $currentprovisioningstate - Next Update In 5 Minutes"
$provisioningstate = Get-AzVirtualNetworkGateway -Name $ExrGatewayForAVS -ResourceGroupName $ExrGWforAVSResourceGroup
$currentprovisioningstate = $provisioningstate.ProvisioningState
}

if("Succeeded" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Green "$timestamp - Virtual Network Gateway is Deployed"
  
}

if("Failed" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Red "$timestamp - Current Status: $currentprovisioningstate

  There appears to be a problem with the deployment of the Virtual Network Gateway "
  Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit $quickeditsettingatstartofscript.QuickEdit
  Exit
}
############################################


Write-Host -ForegroundColor Green "
Generating AVS ExpressRoute Auth Key..."

azurelogin -subtoconnect $sub


$exrauthkey = New-AzVMWareAuthorization -Name "to-ExpressRouteGateway" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub
    Write-Host -ForegroundColor Green "
AVS ExpressRoute Auth Key Generated"

Write-Host -ForegroundColor Yellow "
Connecting the $pcname Private Cloud to Virtual Network Gateway $ExrGatewayForAVS ... "

Set-AzContext -Subscription $vnetgwsub

$exrgwtouse = Get-AzVirtualNetworkGateway -Name $ExrGatewayForAVS -ResourceGroupName $ExrGWforAVSResourceGroup

New-AzVirtualNetworkGatewayConnection -Name "From--$pcname" -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExRGWForAVSRegion -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key
 
Write-host -ForegroundColor Green "
Success: $pcname Private Cloud is Now Connected to to Virtual Network Gateway $ExrGatewayForAVS
"

#Create and Configure Route Server
$virtualnetworkforsubnet = Get-AzVirtualNetwork -Name $VpnGwVnetName

Add-AzVirtualNetworkSubnetConfig -Name "RouteServerSubnet" -VirtualNetwork $virtualnetworkforsubnet -AddressPrefix $RouteServerSubnetAddressPrefix
$virtualnetworkforsubnet | Set-AzVirtualNetwork

$ip = @{
  Name = 'myRouteServerIP'
  ResourceGroupName = $ExrGWforAVSResourceGroup
  Location = $ExRGWForAVSRegion
  AllocationMethod = 'Static'
  IpAddressVersion = 'Ipv4'
  Sku = 'Standard'
}
$publicIp = New-AzPublicIpAddress @ip

$myvnetforrouteserver = Get-AzVirtualNetwork -Name $VpnGwVnetName
$mysubnetforrouteserver = Get-AzVirtualNetworkSubnetConfig -Name "RouteserverSubnet" -VirtualNetwork $myvnetforrouteserver

Write-Host -ForegroundColor Yellow "
Creating RouteServer ... this could take 30-40 minutes ..."

$command = New-AzRouteServer -RouteServerName 'myRouteServer-VPN-To-ExR-For-AVS' -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExRGWForAVSRegion -hostedsubnet $mysubnetforrouteserver.id -PublicIpAddress $publicIp
$command | ConvertTo-Json

$command = Update-AzRouteServer -RouteServerName 'myRouteServer-VPN-To-ExR-For-AVS' -ResourceGroupName $ExrGWforAVSResourceGroup -AllowBranchToBranchTraffic
$command | ConvertTo-Json

}



#######################################################################################
# Connect AVS To vNet w/ ExR
#######################################################################################
azurelogin -subtoconnect $sub


if ("ExpressRoute" -eq $AzureConnection) {
$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub
$peerid = $myprivatecloud.CircuitExpressRouteId
Write-Host -ForegroundColor Yellow "
Generating AVS ExpressRoute Auth Key..."

$exrauthkey = New-AzVMWareAuthorization -Name "to-ExpressRouteGateway" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub
    Write-Host -ForegroundColor Green "
AVS ExpressRoute Auth Key Generated"

Write-Host -ForegroundColor Yellow "
Connecting the $pcname Private Cloud to Virtual Network Gateway $ExrGatewayForAVS ... "

azurelogin -subtoconnect $vnetgwsub

$exrgwtouse = Get-AzVirtualNetworkGateway -ResourceGroupName $ExrGWforAVSResourceGroup -Name $ExrGatewayForAVS

New-AzVirtualNetworkGatewayConnection -Name "From--$pcname" -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExRGWForAVSRegion -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key 
 
Write-host -ForegroundColor Green "
Success: $pcname Private Cloud is Now Connected to to Virtual Network Gateway $ExrGatewayForAVS
"
}
#######################################################################################
# Connecting AVS To On-Prem ExR
#######################################################################################

if ("ExpressRoute" -eq $AzureConnection) {

if ("yes" -eq $internaltest) {

  azurelogin -subtoconnect $sub


    Write-Host -ForegroundColor Yellow "Building Global Reach connection from $pcname to the on-premises Express Route $NameOfOnPremExRCircuit...
    "
    New-AzVMwareGlobalReachConnection -Name $NameOfOnPremExRCircuit -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -AuthorizationKey "$InternalAuthKey" -PeerExpressRouteResourceId "$InternalPeerURI"
    
    $provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
    $currentprovisioningstate = $provisioningstate.CircuitConnectionStatus
    
    while ("Connected" -ne $currentprovisioningstate)
    {
    write-Host -ForegroundColor Yellow "Current Status of Global Reach Connection: $currentprovisioningstate"
    Start-Sleep -Seconds 10
    $provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
    $currentprovisioningstate = $provisioningstate.CircuitConnectionStatus}
    
    if("Connected" -eq $currentprovisioningstate)
    {
      Write-Host -ForegroundColor Green "Success: AVS Private Cloud $pcname is Connected via Global Reach to $NameOfOnPremExRCircuit"
    }  
  
  }
   
  else {
  
    azurelogin -subtoconnect $OnPremExRCircuitSub

    $OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
    Add-AzExpressRouteCircuitAuthorization -Name "For-$pcname" -ExpressRouteCircuit $OnPremExRCircuit
    Set-AzExpressRouteCircuit -ExpressRouteCircuit $OnPremExRCircuit
    
    Write-Host -ForegroundColor Green "
    Success: Auth Key Genereated for AVS On Express Route $NameOfOnPremExRCircuit"
    
    $OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
    $OnPremCircuitAuthDetails = Get-AzExpressRouteCircuitAuthorization -ExpressRouteCircuit $OnPremExRCircuit | Where-Object {$_.Name -eq "For-$pcname"}
    $OnPremCircuitAuth = $OnPremCircuitAuthDetails.AuthorizationKey
    
azurelogin -subtoconnect $sub


New-AzVMwareGlobalReachConnection -Name $NameOfOnPremExRCircuit -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -AuthorizationKey $OnPremCircuitAuth -PeerExpressRouteResourceId $OnPremExRCircuit.Id
    
    $provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
    $currentprovisioningstate = $provisioningstate.CircuitConnectionStatus
    
    while ("Connected" -ne $currentprovisioningstate)
    {
    write-Host -Fore "Current Status of Global Reach Connection: $currentprovisioningstate"
    Start-Sleep -Seconds 10
    $provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
    $currentprovisioningstate = $provisioningstate.CircuitConnectionStatus}
    
    if("Connected" -eq $currentprovisioningstate)
    {
      Write-Host -ForegroundColor Green "Success: AVS Private Cloud $pcname is Connected via Global Reach to $NameOfOnPremExRCircuit"
      
    }
  
  
  }
}

#######################################################################################
# Install HCX To Private Cloud
#######################################################################################

if ($deployhcxyesorno -eq "No") {
  Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit $quickeditsettingatstartofscript.QuickEdit
  Exit
}

else{

  az login
  az config set extension.use_dynamic_install=yes_without_prompt
  az account set --subscription $sub
  write-Host -ForegroundColor Yellow "Deploying VMware HCX to the $pcname Private Cloud ... This will take approximately 20 minutes ... "
 az vmware addon hcx create --resource-group $rgfordeployment --private-cloud $pcname --offer "VMware MaaS Cloud Provider"
  write-Host -ForegroundColor Green "Success: VMware HCX has been deployed to $pcname Private Cloud"
  
  
 
  Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
}  
#######################################################################################
# Get On-Prem vCenter Creds
#######################################################################################  
if ("Yes" -eq $internaltest){

Connect-VIServer -Server $OnPremVIServerIP -username $OnPremVIServerUsername -password $OnPremVIServerPassword

}
else {



write-host -ForegroundColor Yellow "What is the USERNAME and PASSWORD for the ON-PREMISES vCenter Server ($OnPremVIServerIP) where the VMware HCX Connector will be deployed?"
write-host -ForegroundColor White -nonewline "Username: "
$OnPremVIServerUsername = Read-Host 
write-host -ForegroundColor White -nonewline "Password: "
$OnPremVIServerPassword = Read-Host -MaskInput
Connect-VIServer -Server $OnPremVIServerIP -username $OnPremVIServerUsername -password $OnPremVIServerPassword
}

#######################################################################################
# Pick Cluster to Deploy HCX Connector
#######################################################################################
Clear-Host
write-host -foregroundcolor blue "================================="
  
     $clusters = Get-Cluster 
        $Count = 0
        
         foreach ($cluster in $clusters) {
            $clusterlist = $cluster.Name
            Write-Host "$Count - $clusterlist"
            $Count++
         }
         
write-host -foregroundcolor blue "================================="

write-host -ForegroundColor Yellow "
Select the number which corresponds to the Cluster where you would like to deploy the HCX Connector.
SUGGESTION: Pick the Cluster which has the VMs you are going to be migrating."
write-host -ForegroundColor White -nonewline "Selection: "
$Selection = Read-Host
$OnPremCluster = $clusters["$Selection"].Name
Clear-Host
  
  
#######################################################################################
# Pick L2 Extension DVS
#######################################################################################  
write-host -ForegroundColor Yellow -nonewline "
Are you extending L2 VDS portgroups to AVS? (Y/N): "
$Selection = Read-Host

if ($Selection -eq "y") {
write-host -foregroundcolor blue "================================="
       $items =   Get-VDSwitch -Server $OnPremVIServerIP
          $Count = 0
          
           foreach ($item in $items) {
              $list = $item.Name
              Write-Host "$Count - $list"
              $Count++
           }
write-host -foregroundcolor blue "================================="

write-host -ForegroundColor Yellow "
Select the number which corresponds to the VDS which contains the portgroups which will be extended to AVS: "
write-host -ForegroundColor White -nonewline "Selection: "
$Selection = Read-Host
$hcxVDS = $items["$Selection"].Name
Clear-Host

  }
  
  
#######################################################################################
# Define the vMotion Portgroup and Config for the Network Profile
#######################################################################################    
if ("Yes" -eq $internaltest){
    write-host -foregroundcolor blue "================================="
    
    $items = Get-VirtualNetwork
       $Count = 0
       
        foreach ($item in $items) {
           $list = $item.Name
           Write-Host "$Count - $list"
           $Count++
        }
        
        write-host -foregroundcolor blue "================================="

write-host -ForegroundColor Yellow -nonewline "
Select the number of the vMotion Network Portgroup: "
$Selection = Read-Host
$vmotionportgroup = $items["$Selection"].Name


$vmotionprofilegateway = "10.17.0.97"
$vmotionnetworkmask = "27"
$vmotionippool = "10.17.0.106-10.17.0.109"

}

else {
write-host -foregroundcolor blue "================================="
    
       $items = Get-VirtualNetwork
          $Count = 0
          
           foreach ($item in $items) {
              $list = $item.Name
              Write-Host "$Count - $list"
              $Count++
           }
           
           write-host -foregroundcolor blue "================================="

write-host -ForegroundColor Yellow "
Select the number which corresponds to the vMotion Network Portgroup: "
write-host -ForegroundColor White -nonewline "Selection: "
$Selection = Read-Host
$vmotionportgroup = $items["$Selection"].Name
Clear-Host
           
#gateway
write-host -ForegroundColor Yellow -nonewline "
What is the GATEWAY for the vMotion Network on portgroup "$vmotionportgroup"?: "
$Selection = Read-Host
$vmotionprofilegateway = $Selection


#network mask
write-host -ForegroundColor Red "
The entry for Network Prefix must be between 0-32" 
$Selection = Read-Host "What is the $vmotionportgroup Network Prefix?: "
$vmotionnetworkmask = $Selection

#ip range
write-host -ForegroundColor Yellow -nonewline "
Provide three contiguous FREE IP Addresses on the vMotion Network Segment (in this format ... x.x.x.x-x.x.x.x): 
" 
$Selection = Read-Host
$vmotionippool = $Selection
Clear-Host
}
#######################################################################################
# Define the Management Portgroup and Config for the Network Profile
####################################################################################### 
if ("Yes" -eq $internaltest){


    write-host -foregroundcolor blue "================================="
    
    $items = Get-VirtualNetwork
       $Count = 0
       
        foreach ($item in $items) {
           $list = $item.Name
           Write-Host "$Count - $list"
           $Count++
        }
        
        write-host -foregroundcolor blue "================================="

write-host -ForegroundColor Yellow -nonewline "
Select the number of the Management Network Portgroup: "
$Selection = Read-Host
$managementportgroup = $items["$Selection"].Name

$mgmtprofilegateway = "10.17.0.1"
$mgmtnetworkmask = "27"
$mgmtippool = "10.17.0.10-10.17.0.16"


}
else
{


write-host -foregroundcolor blue "================================="
    
       $items = Get-VirtualNetwork
          $Count = 0
          
           foreach ($item in $items) {
              $list = $item.Name
              Write-Host "$Count - $list"
              $Count++
           }
           
           write-host -foregroundcolor blue "================================="

           write-host -ForegroundColor Yellow "
Select the number which corresponds to the Management Network Portgroup: "
           write-host -ForegroundColor White -nonewline "Selection: "
           $Selection = Read-Host
           $managementportgroup = $items["$Selection"].Name
           Clear-Host

#gateway
write-host -ForegroundColor Yellow -nonewline "
What is the GATEWAY for the Management Network on portgroup "$managementportgroup"?: "
$Selection = Read-Host
$mgmtprofilegateway = $Selection

#network mask
write-host -ForegroundColor Red "
The entry for Network Prefix must be between 0-32" 
$Selection = Read-Host "What is the $managementportgroup Network Prefix?: "
$mgmtnetworkmask = $Selection

#ip range
write-host -ForegroundColor Yellow -nonewline "
Provide three contiguous FREE IP Addresses on the Management Network Segment (in this format ... x.x.x.x-x.x.x.x):
" 
$Selection = Read-Host
$mgmtippool = $Selection
Clear-Host

        }
#######################################################################################
# Define the Portgroup To Deploy the HCX Connector
####################################################################################### 
write-host -foregroundcolor blue "================================="
    
       $items = Get-VirtualNetwork
          $Count = 0
          
           foreach ($item in $items) {
              $list = $item.Name
              Write-Host "$Count - $list"
              $Count++
           }
           
           write-host -foregroundcolor blue "================================="
  
write-host -ForegroundColor Yellow  "
Select the number which corresponds to the Portgroup Where You Would Like To Deploy the HCX Connector."
write-host -foregroundcolor Yellow "This is typically the same portgroup which is used for other management type of workloads, but could be any portgroup you like."
write-host -ForegroundColor White -nonewline "Selection: "
$Selection = Read-Host
$VMNetwork = $items["$Selection"].Name
Clear-Host           
 

#######################################################################################
# Pick The Datastore to Use for HCX
#######################################################################################   
  write-host -foregroundcolor blue "================================="
    
       $items = Get-Datastore
          $Count = 0
          
           foreach ($item in $items) {
              $list = $item.Name
              Write-Host "$Count - $list"
              $Count++
           }
           
           write-host -foregroundcolor blue "================================="
  
write-host -ForegroundColor Yellow  "
Select the number which corresponds to the datastore where the HCX Connector and other HCX appliances should be deployed"
write-host -foregroundcolor Yellow "Approximate space required is 165 GB"
write-host -ForegroundColor White -nonewline "Selection: "
$Selection = Read-Host
$Datastore = $items["$Selection"].Name
Clear-Host 

#######################################################################################
  #Define the HCX Connector Deployment Details
#######################################################################################
if ("Yes" -eq $internaltest){
    $HCXVMIP = "10.17.1.147"
    $HCXVMNetmask = "25"
    $HCXVMGateway = "10.17.1.129"
    $HCXVMDNS = "1.1.1.1"
    $HCXVMDomain = "lab.avs.ms"
    $AVSVMNTP = "pool.ntp.org"
$HCXOnPremPassword = "Microsoft.123!"
    $HCXOnPremLocation = "Buffalo"
    $HCXManagerVMName = "AVS-HCX-Connector"

    
  $myprivatecloud = Get-AzVMwarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -Subscription $sub
  $HCXCloudURL = $myprivatecloud.EndpointHcxCloudManager
  $length = $HCXCloudURL.length 
  $HCXCloudIP = $HCXCloudURL.Substring(8,$length-9)

  $HCXCloudPassword = 'X3y)52fp%Ht6'
   $hcxactivationkey = $Selection


}
else
{

  write-Host -foregroundcolor Yellow -nonewline "
  You will now be asked to input the parameters for the HCX Connector OVA Deployment in your on-premises datacenter.  
  This OVA will be deployed to portgroup $VMNetwork
  
  Press Enter Key To Continue"
    $Selection = Read-Host 
    
    write-host -ForegroundColor Yellow -nonewline "VM Name: "
    $Selection = Read-Host
    $HCXManagerVMName = $Selection
  
    
    write-host -ForegroundColor Yellow -nonewline "IP Address: "
    $Selection = Read-Host
    $HCXVMIP = $Selection
  
    #network mask
  write-host -ForegroundColor Red "The entry for Network Prefix must be between 0-32" 
  write-host -ForegroundColor Yellow -nonewline "$VMNetwork Network Prefix?: "
  $Selection = Read-Host
  $HCXVMNetmask = $Selection
  
     
    write-host -ForegroundColor Yellow -nonewline "Gateway for the HCX Connector: "
    $Selection = Read-Host
    $HCXVMGateway = $Selection
  
    write-host -ForegroundColor Yellow -nonewline "DNS Server for the HCX Connector: "
    $Selection = Read-Host
    $HCXVMDNS = $Selection
    
    write-host -ForegroundColor Yellow -nonewline "Domain for the HCX Connector (example: mycompany.com): "
    $Selection = Read-Host
    $HCXVMDomain = $Selection
      
    write-host -ForegroundColor Yellow -nonewline "NTP Server for the HCX Connector (example: pool.ntp.org): "
    $Selection = Read-Host
    $AVSVMNTP = $Selection
    
  #get the hcx admin password
    $hcxadminpasswordvalidate = "NOTsamepassword"
    $warning = ""
    while ("NOTsamepassword" -eq $hcxadminpasswordvalidate)
    
    
    {
    
    
      write-Host -ForegroundColor Red -NoNewline $warning
      write-host -ForegroundColor Yellow -nonewline "Provide a admin password of your choice for the HCX Connector: "
      $Selection1 = Read-Host -MaskInput
      write-host -ForegroundColor Yellow -nonewline "Enter the password again to validate: "
      $Selection2 = Read-Host -MaskInput
      $warning = "
  The Passwords Which Were Entered Do Not Match"
      
      if ($Selection1 -eq $Selection2 ) {      
        $hcxadminpasswordvalidate = "samepassword"
        $HCXOnPremPassword = $Selection1

      }
    
    
    }
    
  
    
    write-host -ForegroundColor Yellow -nonewline "
What is the nearest major city to where the HCX Connector is being deployed?
Example: New York, London, Miami, Melbourne, etc..: "
    $Selection = Read-Host
    $HCXOnPremLocation = $Selection
  
  $myprivatecloud = Get-AzVMwarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -Subscription $sub
  $HCXCloudURL = $myprivatecloud.EndpointHcxCloudManager
  $length = $HCXCloudURL.length 
  $HCXCloudIP = $HCXCloudURL.Substring(8,$length-9)
  
  
  $hcxcloudpasswordvalidate = "NOTsamepassword"
  $warning = ""
  while ("NOTsamepassword" -eq $hcxcloudpasswordvalidate)
  
  
  {
    write-Host -ForegroundColor Red $warning
    write-host -ForegroundColor Yellow -nonewline "Provide password for your HCX Cloud Connector (It's the same password as your CLOUD vCenter). 
You can identify the vCenter and NSX-T Manager console's IP addresses and credentials in the Azure portal. 
Select your PRIVATE CLOUD and then MANAGE > IDENTITY
Password: "
    $Selection1 = Read-Host -MaskInput
    write-host -ForegroundColor Yellow -nonewline "Enter the password again to validate: "
    $Selection2 = Read-Host -MaskInput
    $warning = "
  The Passwords Which Were Entered Do Not Match"
    
    if ($Selection1 -eq $Selection2 ) {      
      $hcxcloudpasswordvalidate = "samepassword"
      $HCXCloudPassword = $Selection1

    }
  }
}

write-host -ForegroundColor Yellow -nonewline "Enter a HCX Activation Key
You can create a HCX Activation Key in the Azure Portal.  
Select your PRIVATE CLOUD > ADD-ONs > MIGRATION USING HCX
Activation Key: "
$Selection = Read-Host
$hcxactivationkey = $Selection



     $HCXOnPremUserID = "admin"
     $mgmtnetworkprofilename = "Management"
     $vmotionnetworkprofilename = "vMotion"
     $hcxactivationurl = "https://connect.hcx.vmware.com"
     $HCXCloudUserID = "cloudadmin@vsphere.local"
     $hcxComputeProfileName = "AVS-ComputeProfile"
     $hcxServiceMeshName = "AVS-ServiceMesh"
     

  Clear-Host
  
  write-Host -foregroundcolor Yellow "Downloading VMware HCX Connector ... "
  $hcxfilename = "VMware-HCX-Connector-4.3.0.0-19068550.ova"
  
  Invoke-WebRequest -Uri https://avsdesignpowerapp.blob.core.windows.net/downloads/$hcxfilename -OutFile $env:TEMP\AVSDeploy\$hcxfilename
  Clear-Host
  write-Host -foregroundcolor Green "Success: VMware HCX Connector Downloaded"
  $HCXApplianceOVA = "$env:TEMP\AVSDeploy\$hcxfilename"
  
  # Connect to vCenter
  Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore
  Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
  Connect-VIServer $OnPremVIServerIP -WarningAction SilentlyContinue -User $OnPremVIServerUsername -Password $OnPremVIServerPassword
  
  # Load OVF/OVA configuration into a variable
  $ovfconfig = Get-OvfConfiguration $HCXApplianceOVA
  $VMHost = Get-Cluster $OnPremCluster | Get-VMHost
  $VMHost = $VMHost.Name.Get(0)
  
  # Fill out the OVF/OVA configuration parameters
  
  # vSphere Portgroup Network Mapping
  $ovfconfig.NetworkMapping.VSMgmt.value = $VMNetwork
  
  # IP Address
  $ovfConfig.common.mgr_ip_0.value = $HCXVMIP
  
  # Netmask
  $ovfConfig.common.mgr_prefix_ip_0.value = $HCXVMNetmask
  
  # Gateway
  $ovfConfig.common.mgr_gateway_0.value = $HCXVMGateway
  
  # DNS Server
  $ovfConfig.common.mgr_dns_list.value = $HCXVMDNS
  
  # DNS Domain
  $ovfConfig.common.mgr_domain_search_list.value  = $HCXVMDomain
  
  # Hostname
  $ovfconfig.Common.hostname.Value = $HCXManagerVMName
  
  # NTP
  $ovfconfig.Common.mgr_ntp_list.Value = $AVSVMNTP
  
  # SSH
  $ovfconfig.Common.mgr_isSSHEnabled.Value = $true
  
  # Password
  $ovfconfig.Common.mgr_cli_passwd.Value = $HCXOnPremPassword
  $ovfconfig.Common.mgr_root_passwd.Value = $HCXOnPremPassword
  
  # Deploy the OVF/OVA with the config parameters
  Write-Host -ForegroundColor Yellow "Deploying HCX Connector OVA ..."
  Import-VApp -Source $HCXApplianceOVA -OvfConfiguration $ovfconfig -Name $HCXManagerVMName -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin
  Write-Host -ForegroundColor Green "Success: HCX Connector Deployed to On-Premises Cluster"

  
  #########################
  # Wait for PowerOn
  #########################
  
  # Power On the HCX Connector VM after deployment
  Write-Host -ForegroundColor Yellow "Powering on HCX Connector ..."
  Start-VM -VM $HCXManagerVMName -Confirm:$false
  Clear-Host
  # Waiting for HCX Connector to initialize
  while(1) {
      try {
          if($PSVersionTable.PSEdition -eq "Core") {
              $requests = Invoke-WebRequest -Uri "https://$($HCXVMIP):9443" -Method GET -SkipCertificateCheck -TimeoutSec 5
          } else {
              $requests = Invoke-WebRequest -Uri "https://$($HCXVMIP):9443" -Method GET -TimeoutSec 5
          }
          if($requests.StatusCode -eq 200) {
              Write-Host -ForegroundColor Green "Success: HCX Connector is now ready to be configured!"
              break
          }
      }
      catch {
          Write-Host -ForegroundColor Yellow "HCX Connector Being Configured ... Still Not Ready ... Will Check Again In 1 Minute ..."
          Start-Sleep 60
      }
  }
  
  
  #########################################
  # Encode the HCX On Prem credentials
  #########################################
  
  $HCXOnPremCredentials = "$HCXOnPremUserID"+":"+"$HCXOnPremPassword"
  $HCXBytes = [System.Text.Encoding]::UTF8.GetBytes($HCXOnPremCredentials)
  $HCXOnPremCredentialsEncoded =[Convert]::ToBase64String($HCXBytes)
  
  
  
  ######################################
  # Get The Certificate From HCX Cloud
  ####################################
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Accept", "application/json")
  $headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")
  
  $body = "{
      `"url`": `"$HCXCloudIP`"
    }
  "
  
  $response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/certificates -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
  $response | ConvertTo-Json
  
  
  
  ##########################
  # Encode The On-Prem vCenter Password
  ##########################
  $HCXBytes = [System.Text.Encoding]::UTF8.GetBytes($OnPremVIServerPassword)
  $OnPremVIServerPasswordEncoded =[Convert]::ToBase64String($HCXBytes)
  
  
  ##########################
  # Connect HCX Connector to OnPrem Vcenter
  ##########################
  
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Accept", "application/json")
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")
  
  $body = "{
    `"data`": {
      `"items`": [
        {
          `"config`": {
            `"url`": `"$OnPremVIServerIP`",
            `"userName`": `"$OnPremVIServerUsername`",
            `"password`": `"$OnPremVIServerPasswordEncoded`"
          }
        }
      ]
    }
  }"
  
  $response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/vcenter -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
  $response | ConvertTo-Json
  
  
  ##########################
  # Define PSC
  ##########################
  
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Accept", "application/json")
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")
  
  $body = "{
      `"data`": {
          `"items`": [
              {
                  `"config`": {
                      `"providerType`": `"PSC`",
                      `"lookupServiceUrl`": `"$PSCIP`"
                  }
              }
          ]
      }
  }"
  
  $response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/lookupservice/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
  
  $response | ConvertTo-Json
  
  
  ######################################
  # Define the Role Mapping
  ####################################
  
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Content-Type", "application/json;charset=UTF-8")
  $headers.Add("Accept", "application/json")
  $headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")
  
  $body = "[
  `n    {
  `n        `"role`": `"System Administrator`",
  `n        `"userGroups`": [
  `n            `"$HCXOnPremRoleMapping`\`\Administrators`"
  `n        ]
  `n    },
  `n    {
  `n        `"role`": `"Enterprise Administrator`",
  `n        `"userGroups`": []
  `n    }
  `n]"
  
  $response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/roleMappings -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
  $response | ConvertTo-Json
  
  
  
  #########################
  # Retrieve Location 
  #########################
  
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Accept", "application/json")
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")
  
  $location = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/searchCities?searchString=$HCXOnPremLocation -Method 'GET' -Headers $headers -Body $body -SkipCertificateCheck
  $location | ConvertTo-Json
  $locationcount = $location.items.Count
  
  if ($locationcount -eq 1 ) {
  
  $city = $location.items.city
  $country = $location.items.country
  $latitude = $location.items.latitude
  $province = $location.items.province
  $longitude = $location.items.longitude
      
  }
  else {
      
  $city = $location.items.city.Item(0)
  $country = $location.items.country.Item(0)
  $latitude = $location.items.latitude.Item(0)
  $province = $location.items.province.Item(0)
  $longitude = $location.items.longitude.Item(0)
  }
  
  $body = "{
            `"city`": `"$city`",
            `"country`": `"$country`",
            `"latitude`": $latitude,
         `"province`": `"$province`",
          `"cityAscii`": `"$city`",
           `"longitude`": $longitude
      }"
  
  $response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/location -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
  $response | ConvertTo-Json
  
  
  ##########################
  #Activate HCX
  ###########################
  if ("" -eq $hcxactivationkey) {
   Write-Host -ForegroundColor Red "You will need to activate HCX Later..."

  }
  else {
    
  
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Accept", "application/json")
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")
  
  $body = "{
        `"data`": {
          `"items`": [
            {
              `"config`": {
                `"url`": `"$hcxactivationurl`",
                `"activationKey`": `"$hcxactivationkey`"
              }
            }
          ]
        }
      }"
  
      
  $response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/hcx -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
  $response | ConvertTo-Json
  
}
  
  ################################
  ## login to HCX Connector and get the session info / Certificate for future API Call
  ###################################
  
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Accept", "application/json")
  
  $body = "{
         `"username`": `"$OnPremVIServerUsername`",
         `"password`": `"$OnPremVIServerPassword`"
     }"
  ##This username and password combination is used because it's the same as the on-prem vcenter
  
  
  $response = Invoke-RestMethod https://$($HCXVMIP)/hybridity/api/sessions -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck -SessionVariable 'Session'
  $response | ConvertTo-Json
  $session
  
  
  ######################################
  # Connect To On Prem HCX Server
  ######################################
  Connect-HCXServer -Server $HCXVMIP -User $OnPremVIServerUsername -Password $OnPremVIServerPassword
    ##This username and password combination is used because it's the same as the on-prem vcenter

 
######################
# Site Pairing
######################
    $command = New-HCXSitePairing -Url $HCXCloudIP -Username $HCXCloudUserID -Password $HCXCloudPassword 
    $command | ConvertTo-Json
        
  

  ######################
  # Create vMotion Network Profile
  ######################
  
  $vmotionnetworkbacking = Get-HCXNetworkBacking -Server $HCXVMIP -Name $vmotionportgroup 
  
  $command = New-HCXNetworkProfile -PrimaryDNS $HCXVMDNS -DNSSuffix $HCXVMDomain -Name $vmotionnetworkprofilename -GatewayAddress $vmotionprofilegateway -IPPool $vmotionippool -Network $vmotionnetworkbacking -PrefixLength $vmotionnetworkmask
  $command | ConvertTo-Json
  
  
  ######################
  # Create Management Netowrk Profile
  ######################
  
  
  $mgmtnetworkbacking = Get-HCXNetworkBacking -Server $HCXVMIP -Name $managementportgroup 
  
  $command = New-HCXNetworkProfile -PrimaryDNS $HCXVMDNS -DNSSuffix $HCXVMDomain -Name $mgmtnetworkprofilename -GatewayAddress $mgmtprofilegateway -IPPool $mgmtippool -Network $mgmtnetworkbacking -PrefixLength $mgmtnetworkmask
  $command | ConvertTo-Json
  
  
  
  ######################
  # Create ComputeProfile
  ######################
  
  
  $managementNetworkProfile = Get-HCXNetworkProfile -Name $mgmtnetworkprofilename
  $vmotionNetworkProfile = Get-HCXNetworkProfile -Name $vmotionnetworkprofilename
  $hcxComputeCluster = Get-HCXApplianceCompute -ClusterComputeResource -Name $OnPremCluster
  $hcxVDS = Get-HCXInventoryDVS -Name $hcxVDS
  $hcxDatastore = Get-HCXApplianceDatastore -Compute $hcxComputeCluster -Name $Datastore

  $command = New-HCXComputeProfile -Name $hcxComputeProfileName -ManagementNetworkProfile $managementNetworkProfile -vMotionNetworkProfile $vmotionNetworkProfile -DistributedSwitch $hcxVDS -Service BulkMigration,Interconnect,Vmotion,WANOptimization,NetworkExtension -Datastore $hcxDatastore -DeploymentResource $hcxComputeCluster -ServiceCluster $hcxComputeCluster
  $command | ConvertTo-Json
  
  
  
  ###############
  #Service Mesh
  ##########
    
  
  $hcxDestinationSite = Get-HCXSite -Destination 
  $hcxLocalComputeProfile = Get-HCXComputeProfile -Name $hcxComputeProfileName
  $hcxRemoteComputeProfileName = Get-HCXComputeProfile -Site $hcxDestinationSite
  $hcxRemoteComputeProfile = Get-HCXComputeProfile -Site $hcxDestinationSite -Name $hcxRemoteComputeProfileName.Name
  $hcxSourceUplinkNetworkProfile = Get-HCXNetworkProfile -Name $managementNetworkProfile
  $command = New-HCXServiceMesh -Name $hcxServiceMeshName -SourceComputeProfile $hcxLocalComputeProfile -Destination $hcxDestinationSite -DestinationComputeProfile $hcxRemoteComputeProfile -SourceUplinkNetworkProfile $hcxSourceUplinkNetworkProfile -Service BulkMigration,Interconnect,Vmotion,WANOptimization,NetworkExtension 
  $command | ConvertTo-Json
  
  
write-host -foregroundcolor Yellow "Building Service Mesh, Script is Paused for 5 Minutes Waiting To Get Status of Service Mesh"
start-sleep -Seconds 300

while ($deploymentstatus -ne "Complete") {
    start-sleep -Seconds 15 
    $status=Get-HCXAppliance
    $status.Status
    if($status.Status -eq "down" -or $null -eq $status.Status){
        $deploymentstatus = "Building"
    write-host "Service Mesh: $deploymentstatus"}
        else{
        $deploymentstatus = "Complete"
        write-host -ForegroundColor Green "Service Mesh: $deploymentstatus"}
  
}


  
  ##########
  #Exit
  ##########
  
  Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit $quickeditsettingatstartofscript.QuickEdit

  write-host -ForegroundColor Yellow -nonewline "
  HCX Is Now Deployed In Your On Premises Cluster, 
  Log into your On-Premises vCenter and You Should See a HCX Plug-In,
  If You Do Not, Log Out of vCenter and Log Back In.

  Press Any Key To Continue
  "
  $Selection = Read-Host
  Start-Process "https://$OnPremVIServerIP"  
    