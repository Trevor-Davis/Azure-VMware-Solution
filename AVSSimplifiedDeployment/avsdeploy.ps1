$quickeditsettingatstartofscript = Get-ItemProperty -Path "HKCU:\Console" -Name Quickedit
Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit 0
$quickeditsettingatstartofscript.QuickEdit


Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

Start-Transcript -Path $env:TEMP\AVSDeploy\avsdeploy.log -Append

###############################################
#Read in the Variables
###############################################
. $env:TEMP\AVSDeploy\variables.ps1

$pcdeployed = 0
$hcxdeployed = 0
$pcexrdeployed = 0
$pconpremdeployed = 0
$hcxonpremdeployed = 0
$hcxclouddeployed = 0
$exrgwforvpndeployed = 0
$avsexrauthkeydeployed = 0
$onpremexrauthkeydeployed = 0
$rsdeployed = 0
$exrglobalreachdeployed = 0

#######################################################################################
#FUNCTIONS
#######################################################################################

$progressPreference = 'silentlyContinue'

$filename = "azureloginfunction.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVSSimplifiedDeployment/$filename" `
-OutFile $env:TEMP\AVSDeploy\$filename
Clear-Host
. $env:TEMP\AVSDeploy\$filename

$filename = "checkavsvcentercommunicationfunction.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVSSimplifiedDeployment/$filename" `
-OutFile $env:TEMP\AVSDeploy\$filename 
Clear-Host
. $env:TEMP\AVSDeploy\$filename

$filename = "getfilesizefunction.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVSSimplifiedDeployment/$filename" `
-OutFile $env:TEMP\AVSDeploy\$filename
Clear-Host
. $env:TEMP\AVSDeploy\$filename


Clear-Host

#######################################################################################
# Check for Installs
#######################################################################################

$filename = "checkprereqs.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVSSimplifiedDeployment/$filename" `
-OutFile $env:TEMP\AVSDeploy\$filename
Clear-Host
Invoke-Expression -Command $env:TEMP\AVSDeploy\$filename

if ($global:powershell7 -eq "no") {
Exit
}

if ($global:count -ne 0) {
  Exit
}
$progressPreference = 'Continue'

#######################################################################################
# Connect To Azure and Validate Sub Is Ready For AVS
#######################################################################################


write-host -ForegroundColor Yellow "
Connecting to your Azure Subscription $sub"


azurelogin -subtoconnect $sub


write-host -ForegroundColor Green "
Azure Login Successful"

Register-AzResourceProvider -ProviderNamespace Microsoft.AVS

$testforpc = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment -ErrorAction Ignore
if ($testforpc.count -eq 1) {
  $pcdeployed=1
}

if ($pcdeployed -eq 0){
Write-Host -ForegroundColor Yellow  "
Validating Subscription Readiness ..." 
$quota = Test-AzVMWareLocationQuotaAvailability -Location $regionfordeployment -SubscriptionId $sub
if ("Enabled" -eq $quota.Enabled)
{

Write-Host -ForegroundColor Green "
Success: Quota is Enabled on Subscription"    

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

}


#######################################################################################
# Define The Resource Group For AVS Deploy
#######################################################################################
 
$testforpc = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment -ErrorAction Ignore
if ($testforpc.count -eq 1) {
  $pcdeployed=1
}

if($pcdeployed -eq 0){

if ( "Existing" -eq $RGNewOrExisting )
{
    write-host -foregroundcolor Green "
AVS Private Cloud Resource Group is $rgfordeployment"
}

if ( "New" -eq $RGNewOrExisting){
   $command = New-AzResourceGroup -Name $rgfordeployment -Location $regionfordeployment

   if ($command.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of the Resource Group $rgfordeployment Failed"
    Exit}

    write-host -foregroundcolor Green "
Success: AVS Private Cloud Resource Group $rgfordeployment Created"   

}
}

#######################################################################################
# Get On-Prem vCenter Creds
#######################################################################################  
if ($deployhcxyesorno -eq "Yes") {

write-host -ForegroundColor Yellow "What is the USERNAME and PASSWORD for the ON-PREMISES vCenter Server ($OnPremVIServerIP) where the VMware HCX Connector will be deployed?"
write-host -ForegroundColor White -nonewline "Username: "
$OnPremVIServerUsername = Read-Host 
write-host -ForegroundColor White -nonewline "Password: "
$OnPremVIServerPassword = Read-Host -MaskInput
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer -Server $OnPremVIServerIP -username $OnPremVIServerUsername -password $OnPremVIServerPassword
}

#######################################################################################
#get the hcx admin password
#######################################################################################
if ($deployhcxyesorno -eq "Yes") {

$hcxadminpasswordvalidate = "NOTsamepassword"
$warning = ""
while ("NOTsamepassword" -eq $hcxadminpasswordvalidate)


{


  write-Host -ForegroundColor Red -NoNewline $warning
  write-host -ForegroundColor Yellow -nonewline "The HCX Connector which will be deployed will create a password for the user 'admin', please provide a password which will be assigned to this user: "
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
}
#######################################################################################
# Kickoff Private Cloud Deployment
#######################################################################################

$testforpc = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment -ErrorAction Ignore
if ($testforpc.count -eq 1) {
  $pcdeployed=1
  write-Host -ForegroundColor Blue "
Azure VMware Solution Private Cloud $pcname Is Already Deployed, Skipping To Next Step..."
}

 
if ($pcdeployed -eq 0) {

Write-Host -ForegroundColor Green "
Success: The Azure VMware Solution Private Cloud Deployment Has Begun"
Write-Host -ForegroundColor Yellow "
Deployment Status Will Begin To Show Shortly"

New-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub -NetworkBlock $addressblock -Sku $skus -Location $regionfordeployment -managementclustersize $numberofhosts -Internet $internet -NoWait -AcceptEULA -ErrorAction Stop

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

}

#######################################################################################
# Connect AVS To vNet w/ VPN GW from On-Prem AND Create Route Server
#######################################################################################


if ("Site-to-Site VPN" -eq $AzureConnection) {
  

#Create Expressroute gateway for AVS to use

azurelogin -subtoconnect $vnetgwsub

$provisioningstate = Get-AzVirtualNetworkGateway -Name $ExrGatewayForAVS -ResourceGroupName $ExrGWforAVSResourceGroup
$currentprovisioningstate = $provisioningstate.ProvisioningState


if ($currentprovisioningstate -eq "Succeeded") {
   
  $exrgwforvpndeployed=1
  write-Host -ForegroundColor Blue "
ExpressRoute Gateway for Azure VMware Solution Private Cloud Is Already Deployed, Skipping To Next Step..."
}

if ($exrgwforvpndeployed -eq 0)

{ 
  
  #start
$ExrGatewayForAVS = "ExRGWfor-$pcname" #the new ExR GW name.
$GWIPName = "ExRGWfor-$pcname-IP" #name of the public IP for ExR GW
$GWIPconfName = "gwipconf" #

azurelogin -subtoconnect $sub

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
if ($pip.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of the Public IP Failed"
Exit}

$ipconf = New-AzVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip
$ipconf

Write-Host -ForegroundColor Yellow "
Creating a ExpressRoute Gateway for AVS ... this could take 30-40 minutes ..."
$command = New-AzVirtualNetworkGateway -Name $ExrGatewayForAVS -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExRGWForAVSRegion -IpConfigurations $ipconf -GatewayType Expressroute -GatewaySku Standard
$command | ConvertTo-Json

$timeStamp = Get-Date -Format "hh:mm"
$provisioningstate = Get-AzVirtualNetworkGateway -Name $ExrGatewayForAVS -ResourceGroupName $ExrGWforAVSResourceGroup
$currentprovisioningstate = $provisioningstate.ProvisioningState
"$timestamp - Current Status: $currentprovisioningstate - Next Update In 5 Minutes"


while ("Succeeded" -ne $currentprovisioningstate)
{
Start-Sleep -Seconds 300
$timeStamp = Get-Date -Format "hh:mm"
$provisioningstate = Get-AzVirtualNetworkGateway -Name $ExrGatewayForAVS -ResourceGroupName $ExrGWforAVSResourceGroup
$currentprovisioningstate = $provisioningstate.ProvisioningState
"$timestamp - Current Status: $currentprovisioningstate - Next Update In 5 Minutes"
}

if("Succeeded" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Green "$timestamp - Virtual Network Gateway is Deployed"
  
}


} #finish


#Connect AVS to vNet

azurelogin -subtoconnect $sub
$status = get-AzVMWareAuthorization -Name "to-ExpressRouteGateway" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub -ErrorAction Ignore

if ($status.count -eq 1) {
write-Host -ForegroundColor Blue "
ExpressRoute Authorization Key Already Generated, Skipping To Next Step..."
}


if ($status.count -eq 0) {

Write-Host -ForegroundColor Green "
Generating AVS ExpressRoute Auth Key..."

$exrauthkey = New-AzVMWareAuthorization -Name "to-ExpressRouteGateway" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub
if ($exrauthkey.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of the AVS ExR Auth Key Failed"
Exit}

    Write-Host -ForegroundColor Green "
AVS ExpressRoute Auth Key Generated"
}

#Connecting private cloud to ExR GW

azurelogin -subtoconnect $vnetgwsub

$status = Get-AzVirtualNetworkGatewayConnection -Name "From--$pcname" -ResourceGroupName $ExrGWforAVSResourceGroup -ErrorAction Ignore


if ($status.count -eq 1 -and $status.ProvisioningState -eq "Succeeded") {
  $pcexrdeployed = 1
  write-Host -ForegroundColor Blue "
Azure VMware Solution Private Cloud Already Connected to Virtual Network Gateway, Skipping To Next Step..."
}


if ($pcexrdeployed -eq 0) {


Write-Host -ForegroundColor Yellow "
Connecting the $pcname Private Cloud to Virtual Network Gateway $ExrGatewayForAVS ... "

$exrgwtouse = Get-AzVirtualNetworkGateway -Name $ExrGatewayForAVS -ResourceGroupName $ExrGWforAVSResourceGroup

$command = New-AzVirtualNetworkGatewayConnection -Name "From--$pcname" -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExRGWForAVSRegion -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key
if ($command.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of the AVS Virtual Network Connection Failed"
Exit}

Write-host -ForegroundColor Green "
Success: $pcname Private Cloud is Now Connected to to Virtual Network Gateway $ExrGatewayForAVS"
}


#Create and Configure Route Server

azurelogin -subtoconnect $vnetgwsub
$status = get-AzRouteServer -RouteServerName 'myRouteServer-VPN-To-ExR-For-AVS' -ResourceGroupName $ExrGWforAVSResourceGroup  -ErrorAction Ignore


if ($status.count -eq 1) {
  $rsdeployed = 1
  write-Host -ForegroundColor Blue "
Azure RouteServer Already Deployed, Skipping To Next Step..."
}


if ($rsdeployed -eq 0) {

$virtualnetworkforsubnet = Get-AzVirtualNetwork -Name $VpnGwVnetName

Add-AzVirtualNetworkSubnetConfig -Name 'RouteServerSubnet' -VirtualNetwork $virtualnetworkforsubnet -AddressPrefix $RouteServerSubnetAddressPrefix
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
if ($command.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of Azure RouteServer Failed"
Exit}

$command = Update-AzRouteServer -RouteServerName 'myRouteServer-VPN-To-ExR-For-AVS' -ResourceGroupName $ExrGWforAVSResourceGroup -AllowBranchToBranchTraffic
$command | ConvertTo-Json

Write-Host -ForegroundColor Green "
Success: Azure RouteServer Created and Updated"
}


$vcentertest = checkavsvcentercommunication


if ($vcentertest -eq "true"){write-Host -foregroundcolor Green "
Success: Communication Between AVS and On-Premises Has Been Validated"
}

else {
          write-Host -ForegroundColor Red "
Communication Between AVS and On-Premises Has Failed.
"
write-host -ForegroundColor Yellow "The VPN Connection appears to have been setup successfully, however, connecting to resources in Azure VMware Solution (vCenter) has failed, most likely this is due to firewall blocking communication.
"
Exit
}

}


#######################################################################################
# Connect AVS To vNet w/ ExR
#######################################################################################

#############11111111111#############
if ("ExpressRoute" -eq $AzureConnection) {

azurelogin -subtoconnect $sub

  
$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub
$peerid = $myprivatecloud.CircuitExpressRouteId


azurelogin -subtoconnect $vnetgwsub

$status = get-AzVMWareAuthorization -Name "to-ExpressRouteGateway" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $vnetgwsub -ErrorAction Ignore
#############2222222222#############
if ($status.count -eq 1) {
  $avsexrauthkeydeployed = 1
  write-Host -ForegroundColor Blue "
ExpressRoute Authorization Key Already Generated, Skipping To Next Step..."
}
#############2222222222#############


#############3333333333#############
if ($avsexrauthkeydeployed -eq 0) {
  
Write-Host -ForegroundColor Yellow "
Generating AVS ExpressRoute Auth Key..."


azurelogin -subtoconnect $sub


$exrauthkey = New-AzVMWareAuthorization -Name "to-ExpressRouteGateway" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub
if ($exrauthkey.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of the AVS ExpressRoute Auth Key Failed"
Exit}
    Write-Host -ForegroundColor Green "
AVS ExpressRoute Auth Key Generated"
}
#############3333333333#############



azurelogin -subtoconnect $vnetgwsub

$status = Get-AzVirtualNetworkGatewayConnection -Name "From--$pcname" -ResourceGroupName $ExrGWforAVSResourceGroup -ErrorAction Ignore
if ($status.count -eq 1 -and $status.ProvisioningState -eq "Succeeded") {
  $pcexrdeployed = 1
  write-Host -ForegroundColor Blue "
Azure VMware Solution Private Cloud Already Connected to Virtual Network Gateway, Skipping To Next Step..."
}




if ($pcexrdeployed -eq 0) {

Write-Host -ForegroundColor Yellow "
Connecting the $pcname Private Cloud to Virtual Network Gateway $ExrGatewayForAVS ... "

$exrauthkey = Get-AzVMwareAuthorization -Name "to-ExpressRouteGateway" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub
$exrgwtouse = Get-AzVirtualNetworkGateway -ResourceGroupName $ExrGWforAVSResourceGroup -Name $ExrGatewayForAVS

$command = New-AzVirtualNetworkGatewayConnection -Name "From--$pcname" -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExRGWForAVSRegion -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key 
if ($command.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of the AVS Virtual Network Gateway Connection Failed"
Exit}

Write-host -ForegroundColor Green "
Success: $pcname Private Cloud is Now Connected to to Virtual Network Gateway $ExrGatewayForAVS"
}





}

#######################################################################################
# Connecting AVS To On-Prem ExR
#######################################################################################

if ("ExpressRoute" -eq $AzureConnection) {

  #generate auth key on on-prem ExR circut
  
  

  azurelogin -subtoconnect $OnPremExRCircuitSub
  
  $OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
  $status = get-AzExpressRouteCircuitAuthorization -Name "For-$pcname" -ExpressRouteCircuit $OnPremExRCircuit -ErrorAction Ignore
  
      if ($status.count -eq 1) {
        $onpremexrauthkeydeployed = 1
        write-Host -ForegroundColor Blue "
On-Premises ExpressRoute Authorization Key Already Generated, Skipping To Next Step..."
      }
  
      if ($onpremexrauthkeydeployed -eq 0){
        Write-Host -ForegroundColor Yellow "
Generating Auth Key for AVS Global Reach Connection ... "
      $OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
      $command=Add-AzExpressRouteCircuitAuthorization -Name "For-$pcname" -ExpressRouteCircuit $OnPremExRCircuit
      if ($command.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of the On-Prem Authorization Key Failed"
  Exit}
      Set-AzExpressRouteCircuit -ExpressRouteCircuit $OnPremExRCircuit
      
      Write-Host -ForegroundColor Green "
Success: Auth Key Genereated for AVS On Express Route $NameOfOnPremExRCircuit"
    }
  
    
  
      $OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
      $OnPremCircuitAuthDetails = Get-AzExpressRouteCircuitAuthorization -ExpressRouteCircuit $OnPremExRCircuit | Where-Object {$_.Name -eq "For-$pcname"}
      $OnPremCircuitAuth = $OnPremCircuitAuthDetails.AuthorizationKey
      
    #Connect Global Reach
    
  azurelogin -subtoconnect $sub
  
  
     $status = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -ErrorAction Ignore
     if ($status.count -eq 1 -and $status.CircuitConnectionStatus -eq "Connected") {
      $exrglobalreachdeployed = 1
      write-Host -ForegroundColor Blue "
ExpressRoute GlobalReach Connection Established Already, Skipping To Next Step..."
    }
    
    if ($exrglobalreachdeployed -eq 0) {
      Write-Host -ForegroundColor Yellow "
Connecting the $pcname Private Cloud to On-Premises via Global Reach... " 
      
      $command=New-AzVMwareGlobalReachConnection -Name $NameOfOnPremExRCircuit -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -AuthorizationKey $OnPremCircuitAuth -PeerExpressRouteResourceId $OnPremExRCircuit.Id
  
      $provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
      $currentprovisioningstate = $provisioningstate.CircuitConnectionStatus
      
      while ("Connected" -ne $currentprovisioningstate)
      {
        if ($command.ProvisioningState -eq "Failed"){Write-Host -ForegroundColor Red "Creation of the AVS Global Reach Connection Failed"
        Exit}
        
        write-Host -ForegroundColor Yellow "Current Status of Global Reach Connection: $currentprovisioningstate"
      Start-Sleep -Seconds 10
      $provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
      $currentprovisioningstate = $provisioningstate.CircuitConnectionStatus}
      $currentprovisioningstate = 'Connected'
      if("Connected" -eq $currentprovisioningstate)
      {
        Write-Host -ForegroundColor Green "
Success: AVS Private Cloud $pcname is Connected via Global Reach to $NameOfOnPremExRCircuit"
        }
    }
    
  
  $vcentertest = checkavsvcentercommunication
  
  
  if ($vcentertest -eq "true"){
    write-Host -foregroundcolor Green "
Success: Communication Between AVS and On-Premises Has Been Validated"
  }
  
  else {
            write-Host -ForegroundColor Red "
  Communication Between AVS and On-Premises Has Failed.
  "
  write-host -ForegroundColor Yellow "The Global Reach Connection appears to have been setup successfully, however, connecting to resources in Azure VMware Solution (vCenter) has failed, most likely this is due to firewall blocking communication.
  "
  Exit
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

azurelogin -subtoconnect $sub


   $status = Get-AzVMwareAddon -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -ErrorAction Ignore
   if ($status.name -eq "hcx") {
    $hcxdeployed = 1
    write-Host -ForegroundColor Blue "
HCX Has Already Been Deployed to $pcname Private Cloud, Skipping To Next Step..."
  }


if ($hcxdeployed -eq 0) {
  az login
  az config set extension.use_dynamic_install=yes_without_prompt
  az account set --subscription $sub
  Clear-Host
  write-Host -ForegroundColor Yellow "Deploying VMware HCX to the $pcname Private Cloud ... This will take approximately 30 minutes ... "
 az vmware addon hcx create --resource-group $rgfordeployment --private-cloud $pcname --offer "VMware MaaS Cloud Provider"
  write-Host -ForegroundColor Green "Success: VMware HCX has been deployed to $pcname Private Cloud"
   
}
}  


#######################################################################################
#Get HCX Cloud IP Address and Password
#######################################################################################

azurelogin -subtoconnect $sub


#IP Address
  $myprivatecloud = Get-AzVMwarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -Subscription $sub
  $HCXCloudURL = $myprivatecloud.EndpointHcxCloudManager
  $length = $HCXCloudURL.length 
  $HCXCloudIP = $HCXCloudURL.Substring(8,$length-9)

#Password

$command = Get-AzVMwarePrivateCloudAdminCredential -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
$HCXCloudPassword = ConvertFrom-SecureString -SecureString $command.VcenterPassword -AsPlainText



#######################################################################################
#Get HCX Activation Key
#######################################################################################
write-host -ForegroundColor Yellow -nonewline "Enter a HCX Activation Key
You can create a HCX Activation Key in the Azure Portal.  
Select your PRIVATE CLOUD > ADD-ONs > MIGRATION USING HCX
Activation Key: "
$Selection = Read-Host
$hcxactivationkey = $Selection


#######################################################################################
#Deploy HCX OVA On-Prem
#######################################################################################
  Clear-Host
  
  #download the HCX OVA


  $HCXApplianceOVA = "$env:TEMP\AVSDeploy\$hcxfilename"

  
  $checkhcxfilesize = getfilesize -filename $HCXApplianceOVA
  

  if ($checkhcxfilesize -ne "3.0418777465820312")
  {
    write-Host -foregroundcolor Yellow "Downloading VMware HCX Connector ... "
    Invoke-WebRequest -Uri https://avsdesignpowerapp.blob.core.windows.net/downloads/$hcxfilename -OutFile $env:TEMP\AVSDeploy\$hcxfilename
    Clear-Host
    write-Host -foregroundcolor Green "Success: VMware HCX Connector Downloaded"
  }


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
 
  $requestvcenter = Invoke-WebRequest -Uri "https://$($OnPremVIServerIP):443" -Method GET -SkipCertificateCheck -TimeoutSec 5
  if ($requestvcenter.StatusCode -ne 200) {
write-Host -ForegroundColor Red "The machine this script is running from cannot reach the vCenter Server on port 443, please resolve this issue and re-run the script."
Exit
  }

  $requesthost = Test-Connection -IPv4 -TcpPort 902 $VMHost
  if ($requesthost -ne "True") {
write-Host -ForegroundColor Red "The machine this script is running from cannot reach the VMware environment on port 902 to deploy the OVA, please resolve this issue and re-run the script."
Exit
  }


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
          Write-Host -ForegroundColor Yellow "Powering On HCX Connector ... Still Getting Ready ... Will Check Again In 1 Minute ..."
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

If ($HCXOnPremRoleMapping -eq "") {
  Write-Host -ForegroundColor Green "HCX Role Mapping Set To vsphere.local\Administrators"
    }
    else{  
    $refcharacter = $HCXOnPremRoleMapping.IndexOf("\")
    $ssodomain = $HCXOnPremRoleMapping.Substring(0,$refcharacter)
    $ssogroup = $HCXOnPremRoleMapping.Substring($refcharacter+1)
    
    
      $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
      $headers.Add("Content-Type", "application/json;charset=UTF-8")
      $headers.Add("Accept", "application/json")
      $headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")
      
      $body = "[
      `n    {
      `n        `"role`": `"System Administrator`",
      `n        `"userGroups`": [
      `n            `"$ssodomain`\`\$ssogroup`"
      `n        ]
      `n    },
      `n    {
      `n        `"role`": `"Enterprise Administrator`",
      `n        `"userGroups`": []
      `n    }
      `n]"
      
      $response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/roleMappings -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
      $response | ConvertTo-Json
  
      Write-Host -ForegroundColor Green "HCX Role Mapping Set To $ssodomain\$ssogroup"
  
    }
  
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
    Write-Host -ForegroundColor Red "You did not enter an HCX Activation Key, HCX will be deployed in evaluation mode."
    
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
  $connecthcx = Connect-HCXServer -Server $HCXVMIP -User $OnPremVIServerUsername -Password $OnPremVIServerPassword -ErrorAction:SilentlyContinue
  while ($connecthcx.IsConnected -ne "True" ) {
    Write-Host -ForegroundColor yellow 'Waiting for On-Premises HCX Connector Services To Re-Start ... Checking Again In 1 Minute ....'
    Start-Sleep -Seconds 60
    $connecthcx = Connect-HCXServer -Server $HCXVMIP -User $OnPremVIServerUsername -Password $OnPremVIServerPassword -ErrorAction:SilentlyContinue
  
  }

######################
# Site Pairing
######################
    $command = New-HCXSitePairing -Url https://$($HCXCloudIP) -Username $HCXCloudUserID -Password $HCXCloudPassword -Server $HCXVMIP
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
  $hcxDatastore = Get-HCXApplianceDatastore -Compute $hcxComputeCluster -Name $Datastore

  if ($l2networkextension -eq "Yes") {
    $hcxVDS = Get-HCXInventoryDVS -Name $hcxVDS
    $command = New-HCXComputeProfile -Name $hcxComputeProfileName -ManagementNetworkProfile $managementNetworkProfile -vMotionNetworkProfile $vmotionNetworkProfile -DistributedSwitch $hcxVDS -Service BulkMigration,Interconnect,Vmotion,WANOptimization,NetworkExtension -Datastore $hcxDatastore -DeploymentResource $hcxComputeCluster -ServiceCluster $hcxComputeCluster 

  }

  if ($l2networkextension -eq "No") {
    $command = New-HCXComputeProfile -Name $hcxComputeProfileName -ManagementNetworkProfile $managementNetworkProfile -vMotionNetworkProfile $vmotionNetworkProfile -Service BulkMigration,Interconnect,Vmotion,WANOptimization -Datastore $hcxDatastore -DeploymentResource $hcxComputeCluster -ServiceCluster $hcxComputeCluster -Server $HCXVMIP

  }

  $command | ConvertTo-Json
  
  
  
  ###############
  #Service Mesh
  ##########
    
  $hcxDestinationSite = Get-HCXSite -Destination 
  $hcxDestinationSite
  $hcxLocalComputeProfile = Get-HCXComputeProfile -Name $hcxComputeProfileName -Server $HCXVMIP
  $hcxLocalComputeProfile
  $hcxRemoteComputeProfileName = Get-HCXComputeProfile -Site $hcxDestinationSite
  $hcxRemoteComputeProfileName
  $hcxRemoteComputeProfile = Get-HCXComputeProfile -Site $hcxDestinationSite -Name $hcxRemoteComputeProfileName.Name
  $hcxRemoteComputeProfile
  $hcxSourceUplinkNetworkProfile = Get-HCXNetworkProfile -Name $mgmtnetworkprofilename -Server $hcxvmip
  $hcxSourceUplinkNetworkProfile
  $remoteuplinknetworkprofilename = $hcxRemoteComputeProfile.Network.Name -like '*uplink*'
  $remoteuplinknetworkprofilename
  $remoteuplinknetworkprofile = Get-HCXNetworkProfile -Site $hcxDestinationSite -Name $remoteuplinknetworkprofilename 
  $remoteuplinknetworkprofile

  if ($l2networkextension -eq "Yes") {
    $command = New-HCXServiceMesh -Name $hcxServiceMeshName `
    -SourceComputeProfile $hcxLocalComputeProfile `
    -DestinationComputeProfile $hcxRemoteComputeProfile `
    -Destination $hcxDestinationSite `
    -SourceUplinkNetworkProfile $hcxSourceUplinkNetworkProfile `
    -DestinationUplinkNetworkProfile $remoteuplinknetworkprofile `
    -Service BulkMigration,Interconnect,Vmotion,WANOptimization,NetworkExtension -Server $HCXVMIP
    $command | ConvertTo-Json
  
  }

  if ($l2networkextension -eq "No") {
    $command = New-HCXServiceMesh -Name $hcxServiceMeshName `
    -SourceComputeProfile $hcxLocalComputeProfile `
    -DestinationComputeProfile $hcxRemoteComputeProfile `
    -Destination $hcxDestinationSite `
    -SourceUplinkNetworkProfile $hcxSourceUplinkNetworkProfile `
    -DestinationUplinkNetworkProfile $remoteuplinknetworkprofile `
    -Service BulkMigration,Interconnect,Vmotion,WANOptimization -Server $HCXVMIP
    $command | ConvertTo-Json
  
  }

  #testing service mesh
  
  $testhcxservicemeshIXI1 = get-hcxappliance -name "$hcxServiceMeshName-IX-I1" 
#  $testhcxservicemeshIXR1 = get-hcxappliance -name "$hcxServiceMeshName-IX-R1"
  $deploymentstatus = "Building"
  write-host -ForegroundColor Yellow "Service Mesh: $deploymentstatus - Next Update in 60 Seconds"
  

while ($deploymentstatus -ne "Complete") {

    start-sleep -Seconds 60 
    $testhcxservicemeshIXI1 = get-hcxappliance -name "$hcxServiceMeshName-IX-I1"
#    $testhcxservicemeshIXR1 = get-hcxappliance -name "$hcxServiceMeshName-IX-R1"
    
    if ($testhcxservicemeshIXI1.TunnelStatus -ne "up"){
      $deploymentstatus = "Building"
      write-host -ForegroundColor Yellow "Service Mesh: $deploymentstatus - Next Update in 60 Seconds"
    }
   
    if ($testhcxservicemeshIXI1.TunnelStatus -eq "up"){
      $deploymentstatus = "Complete"
      write-host -ForegroundColor Green "Service Mesh: $deploymentstatus"
    }

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