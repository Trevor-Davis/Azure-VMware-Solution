$internaltest="No" #put yes if this is an internal test
$InternalAuthKey = ""
$InternalPeerURI = ""

#######################################################################################
# Read In Variables
#######################################################################################
$sub = "Sub for AVS Private Cloud" #subfordeployment
$regionfordeployment = "Region for deployment of AVS" #regionfordeployment
$pcname = "Name of AVS Private Cloud" #NameOfAVSPC
$skus = "AVS Private Cloud SKU (AV36 or AV36T for Trial Nodes)" #SKUType
$addressblock = "The /22 Network Block for AVS" #AVSAddressBlock
$ExrGatewayForAVS = "The ExR GW Name The AVS Private Cloud Will Connect" #existingvnetgwname
$deployhcxyesorno = "Yes Or No" #DeployHCX
$ExrGWforAVSResourceGroup = "The Resource Group of the ExR GW Which AVS Will Connect" #RGofOnPremExRCircuit
$NameOfOnPremExRCircuit = "The name of the on-prem ExR Circuit" #NameOfOnPremExRCircuit
$ExRGWForAVSRegion = "The ExR GW Region for AVS" #ExRGWForAVSRegion

$RGofOnPremExRCircuit = "The RG where the the On-Prem ExR is deployed" #RGofOnPremExRCircuit
$internet = "Enabled"
$numberofhosts = "3"

$RGNewOrExisting = "New Or Existing ... Use an existing RG for AVS or create a new one" #RGforAVSNewOrExisting
if("New" -eq $RGNewOrExisting)
{
$rgfordeployment = "Name of the new resource group" #rgfordeployment
}
else {
$rgfordeployment = "Name of the existing RG" #rgfordeployment
}


$SameSubAVSAndExRGW = "Yes or No ... Does AVS and the ExR GW connecting in the same subscriptoin?" #SameSubAVSAndExRGW
if ("Yes" -eq $SameSubAVSAndExRGW) {
$OnPremExRCircuitSub = $sub
}
else {
    $OnPremExRCircuitSub = "The sub where the ExR is deployed" #OnPremExRCircuitSub
    
}

  
$OnPremVIServerIP = "the On Prem vCenter server IP " #OnPremVIServerIP
$PSCSameAsvCenterYesOrNo = "Is the PSC the same IP as the vCenter Server? ... Yes or No" #PSCIPSameAsVcenterYesOrNo

if ($PSCSameAsvCenterYesOrNo -eq "Yes" ) {
  $PSCIP = $OnPremVIServerIP
}
else {
  $PSCIP = "The PSCIP" #PSCIP
  
}

$HCXOnPremRoleMapping = "What is the SSO domain for vCenter, i.e., vsphere.local, mycompany.local" #HCXOnPremRoleMapping

#######################################################################################
# Create Temp Storage Location
#######################################################################################

mkdir $env:TEMP\AVSDeploy
Clear-Host

#######################################################################################
# Check for Installs
#######################################################################################
#PowerShell 7

Write-Host -ForegroundColor White "Checking The Local System To Verify The Following Items Are Installed, If They Aren't Already Installed You Will Have The Option To Install Them:
- PowerShell 7.x
- AZ and the AZ.VMware Powershell Modules
- VMware PowerCLI Modules
- Azure CLI
"
if ($PSVersionTable.PSVersion.Major -lt 7){
  $PSVersion = $PSVersionTable.PSVersion.Major
  Write-Host -NoNewline -ForegroundColor Yellow "Your Powershell Version Is $PSVersion ... Would You Like To Upgrade To Powershell Version 7 Now? (Y/N): "
  $PSVersionUpgrade = Read-Host 
  
  if ($PSVersionUpgrade -eq "y"){
  
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  $PowerShellDownloadURL = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi"
  $PowerShellDownloadFileName = "PowerShell-7.2.1-win-x64.msi"
  Invoke-WebRequest -Uri $PowerShellDownloadURL -OutFile $env:TEMP\AVSDeploy\$PowerShellDownloadFileName 
  Start-Process -wait "$env:TEMP\AVSDeploy\$PowerShellDownloadFileName"
  Write-Host -ForegroundColor Green "
  Success: PowerShell Upgraded"
}
Write-Host  "
Powershell Version 7 Is a Requirement For This Script" -ForegroundColor Red
Exit
}

#Az and Az.VMware Powershell Modules

$vmwareazcheck = Find-Module -Name Az
if ($vmwareazcheck.Name -ne "Az") {
  Write-Host -NoNewline -ForegroundColor Yellow "The AZ and the AZ.VMware Powershell Modules Are NOT Installed, Would You Like To Install Those Now? (Y/N): "
  $AZModuleInstall = Read-Host 
  
  if ($AZModuleInstall -eq "y"){
  
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned 
  Write-Host -ForegroundColor Yellow "Installing Azure Powershell Modules ..."
  Install-Module -Name Az -Repository PSGallery -Force
  Install-Module -Name Az.VMware -Repository PSGallery -Force


  Write-Host -ForegroundColor Green "
  Success: Azure Powershell Modules Installed"

}
Write-Host  "Az and Az.VMware Powershell Modules Are Requirements For This Script" -ForegroundColor Red
Exit
}


#VMware PowerCLI Modules
$vmwarepowerclicheck = Find-Module -Name VMware.PowerCLI
if ($vmwarepowerclicheck.Name -ne "VMware.PowerCLI") {
    Write-Host -NoNewline -ForegroundColor Yellow "The VMware PowerCLI Modules Are Not Installed, Would You Like To Install Those Now? (Y/N): "
    $VMwarePowerCLIInstall = Read-Host 
    
    if ($VMwarePowerCLIInstall -eq "y"){
    
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned 
    Write-Host -ForegroundColor Yellow "Installing VMware PowerCLI Modules ..."
    Install-Module -Name VMware.PowerCLI -Force
    Install-Module -Name VMware.VimAutomation.Hcx -Force


    Write-Host -ForegroundColor Green "
    Success: VMware PowerCLI Modules Installed"

}
Write-Host  "VMware PowerCLI Modules Are Requirements For This Script" -ForegroundColor Red
Exit
}


$vmwarepowerclihcxcheck = Find-Module -Name VMware.VimAutomation.Hcx
if ($vmwarepowerclihcxcheck.Name -ne "VMware.VimAutomation.Hcx") {
    Write-Host -NoNewline -ForegroundColor Yellow "The VMware HCX PowerCLI Module Is Not Installed, Would You Like To Install It Now? (Y/N): "
    $VMwarePowerCLIHCXInstall = Read-Host 
    
    if ($VMwarePowerCLIHCXInstall -eq "y"){
    
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned 
    Write-Host -ForegroundColor Yellow "Installing VMware HCX PowerCLI Module ..."
    Install-Module -Name VMware.VimAutomation.Hcx -Force


    Write-Host -ForegroundColor Green "
    Success: VMware HCX PowerCLI Modules Installed"

}
Write-Host  "VMware HCX PowerCLI Module Is Required For This Script" -ForegroundColor Red
Exit
}
  
#Azure CLI

$software = "Azure CLI"
$installed = "Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -contains $software }" -ne $null

if ("False" -eq $installed) {
    Write-Host -nonewline -ForegroundColor Yellow "It Appears Azure CLI Is NOT Installed On This Computer, Would You Like To Install It Now (Y/N): "
    $begin = Read-Host

    if ("y" -eq $begin ) {
      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned 
      $azureCLIDownloadURL = "https://aka.ms/installazurecliwindows"
      $azureCLIDownloadFileName = "AzureCLI.msi"
      Invoke-WebRequest -Uri $azureCLIDownloadURL -OutFile $env:TEMP\AVSDeploy\$azureCLIDownloadFileName 
      Start-Process -wait "$env:TEMP\AVSDeploy\$azureCLIDownloadFileName"
      Write-Host -ForegroundColor Green "
      Success: Azure CLI Installed"
      
    }

    Write-Host  "Azure CLI Program Is Required For This Script" -ForegroundColor Red
    Exit

  }
    

#######################################################################################
# Connect To Azure and Validate Sub Is Ready For AVS
#######################################################################################

write-host -ForegroundColor Yellow "
Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
Connect-AzAccount -Subscription $sub
write-host -ForegroundColor Green "
Azure Login Successful
"
Write-Host -ForegroundColor Yellow  "
Validating Subscription Readiness ..." 

$quota = Test-AzVMWareLocationQuotaAvailability -Location $regionfordeployment -SubscriptionId $sub

if ("Enabled" -eq $quota.Enabled)
{

Write-Host -ForegroundColor Green "
Success: Quota is Enabled on Subscription
"    

Register-AzResourceProvider -ProviderNamespace Microsoft.AVS

Write-Host -ForegroundColor Green "
Success: Resource Provider Enabled
"    

}

Else

{
Write-Host -ForegroundColor Red "
Subscription $sub Does NOT Have Quota for Azure VMware Solution, please visit the following site for guidance on how to get this service enabled for your subscription.

https://docs.microsoft.com/en-us/azure/azure-vmware/enable-azure-vmware-solution"

Exit

}

#######################################################################################
# Define The Resource Group For AVS Deploy
#######################################################################################

if ( "Existing" -eq $RGNewOrExisting )
{
    write-host -foregroundcolor Green "
AVS Private Cloud Resource Group is $rgfordeployment"
}

if ( "New" -eq $RGNewOrExisting){
    New-AzResourceGroup -Name $rgfordeployment -Location $regionfordeployment

    write-host -foregroundcolor Green = "
Success: AVS Private Cloud Resource Group $rgfordeployment Created"   

}

#######################################################################################
# Kickoff Private Cloud Deployment
#######################################################################################

Write-Host -ForegroundColor Green "
Success: The Azure VMware Solution Private Cloud Deployment Has Begun
"
Write-Host -ForegroundColor White "
Deployment Status Will Begin To Show Shortly
"
New-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub -NetworkBlock $addressblock -Sku $skus -Location $regionfordeployment -managementclustersize $numberofhosts -Internet $internet -NoWait -AcceptEULA

Write-Host -foregroundcolor Magenta "
The Azure VMware Solution Private Cloud $pcname deployment is underway and will take approximately 4 hours.
"
Write-Host -foregroundcolor Yellow "
The status of the deployment will update every 5 minutes.
"

Start-Sleep -Seconds 300

$provisioningstate = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"


while ("Succeeded" -ne $currentprovisioningstate)
{
$timeStamp = Get-Date -Format "hh:mm"
"$timestamp - Current Status: $currentprovisioningstate "
Start-Sleep -Seconds 300
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

  Exit

}
#>

#######################################################################################
# Connect AVS To vNet
#######################################################################################

$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub
$peerid = $myprivatecloud.CircuitExpressRouteId
Write-Host -ForegroundColor Yellow "
Generating AVS ExpressRoute Auth Key..."

$exrauthkey = New-AzVMWareAuthorization -Name "Connection-To-$ExrGatewayForAVS" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment 
if ($exrauthkey.ProvisioningState -eq "Succeeded" ) {
    Write-Host -ForegroundColor Green "
AVS ExpressRoute Auth Key Generated"
    }
    if ($exrauthkey.ProvisioningState -ne "Succeeded" ) {
        Write-Host -ForegroundColor Red "
AVS ExpressRoute Auth Key Generation Failed"
        Exit
        }

Write-Host -ForegroundColor Yellow "
Connecting the $pcname Private Cloud to Virtual Network Gateway $ExrGatewayForAVS ... "

$exrgwtouse = Get-AzVirtualNetworkGateway -ResourceGroupName $ExrGWforAVSResourceGroup -Name $ExrGatewayForAVS
New-AzVirtualNetworkGatewayConnection -Name "From--$pcname" -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExrForAVSRegion -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key 
 
Write-host -ForegroundColor Green "
Success: $pcname Private Cloud is Now Connected to to Virtual Network Gateway $ExrGatewayForAVS
"

#######################################################################################
# Connecting AVS To On-Prem ExR
#######################################################################################

if ("yes" -eq $internaltest) {

    Select-AzSubscription -SubscriptionId $sub
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
  
  
    Select-AzSubscription -SubscriptionId $OnPremExRCircuitSub
  
    $OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
    Add-AzExpressRouteCircuitAuthorization -Name "For-$pcname" -ExpressRouteCircuit $OnPremExRCircuit
    Set-AzExpressRouteCircuit -ExpressRouteCircuit $OnPremExRCircuit
    
    Write-Host -ForegroundColor Green "
    Success: Auth Key Genereated for AVS On Express Route $NameOfOnPremExRCircuit"
    
    $OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
    $OnPremCircuitAuthDetails = Get-AzExpressRouteCircuitAuthorization -ExpressRouteCircuit $OnPremExRCircuit | Where-Object {$_.Name -eq "For-$pcname"}
    $OnPremCircuitAuth = $OnPremCircuitAuthDetails.AuthorizationKey
    
    Select-AzSubscription -SubscriptionId $sub
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
  
#######################################################################################
# Install HCX To Private Cloud
#######################################################################################

if ($deployhcxyesorno -eq "No") {
  Exit
}

else
{

  az login
  az account set --subscription $sub
  write-Host -ForegroundColor Yellow "Deploying VMware HCX to the $pcname Private Cloud ... This will take approximately 45 minutes ... "
  az vmware addon hcx create --resource-group $rgfordeployment --private-cloud $pcname --offer "VMware MaaS Cloud Provider"
  write-Host -ForegroundColor Green "Success: VMware HCX has been deployed to $pcname Private Cloud"
  
  
 
  Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
  
#######################################################################################
# Get On-Prem vCenter Creds
#######################################################################################  
write-host -ForegroundColor Yellow -nonewline "What Is The Username for the ON-PREMISES vCenter Server ($OnPremVIServerIP) Where HCX Connector Will Be Deployed?: "
$OnPremVIServerUsername = Read-Host 
write-host -ForegroundColor Yellow -nonewline "What Is The Password for the ON-PREMISES vCenter Server ($OnPremVIServerIP) Where HCX Connector Will Be Deployed?: "
$OnPremVIServerPassword = Read-Host -MaskInput
Connect-VIServer -Server $OnPremVIServerIP -username $OnPremVIServerUsername -password $OnPremVIServerPassword
  
write-host -foregroundcolor blue "================================="
  
     $clusters = Get-Cluster 
        $Count = 0
        
         foreach ($cluster in $clusters) {
            $clusterlist = $cluster.Name
            Write-Host "$Count - $clusterlist"
            $Count++
         }
         
write-host -foregroundcolor blue "================================="

write-host -ForegroundColor Yellow -nonewline "
Select the number which corresponds to the Cluster where you would like to deploy the HCX Connector (SUGGESTION: pick the one which has the VMs you are going to be migrating): "
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

write-host -ForegroundColor Yellow -nonewline "
Select the switch from this list which contgains the portgroups which will be extended to AVS: "
$Selection = Read-Host
$hcxVDS = $items["$Selection"].Name
Clear-Host
  }
  
  
#######################################################################################
# Define the vMotion Portgroup and Config for the Network Profile
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

write-host -ForegroundColor Yellow -nonewline "
Select the number of the vMotion Network Portgroup: "
$Selection = Read-Host
$vmotionportgroup = $items["$Selection"].Name

write-host -ForegroundColor Yellow -nonewline "
What is the Gateway for the vMotion Network on portgroup "$vmotionportgroup"?: "
$Selection = Read-Host
$vmotionprofilegateway = $Selection

write-host -ForegroundColor Yellow -nonewline "
What is the Netmask for the vMotion Network (in this format /xx ... DO NOT INCLUDE THE / ) on portgroup "$vmotionportgroup"?: "
$Selection = Read-Host
$vmotionnetworkmask = $Selection

write-host -ForegroundColor Yellow -nonewline "
Provide three contiguous FREE IP Addresses on the vMotion Network Segment (in this format ... x.x.x.x-x.x.x.x): " 
$Selection = Read-Host
$vmotionippool = $Selection
Clear-Host

#######################################################################################
# Define the Management Portgroup and Config for the Network Profile
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

write-host -ForegroundColor Yellow -nonewline "
Select the number of the Management Network Portgroup: "
$Selection = Read-Host
$managementportgroup = $items["$Selection"].Name

write-host -ForegroundColor Yellow -nonewline "
What is the Gateway for the Management Network on portgroup "$managementportgroup"?: "
$Selection = Read-Host
$mgmtprofilegateway = $Selection

write-host -ForegroundColor Yellow -nonewline "
What is the Netmask for the Management Network (in this format /xx ... DO NOT INCLUDE THE / ) on portgroup "$managementportgroup"?: "
$Selection = Read-Host
$mgmtnetworkmask = $Selection

write-host -ForegroundColor Yellow -nonewline "
Provide three contiguous FREE IP Addresses on the Management Network Segment (in this format ... x.x.x.x-x.x.x.x): " 
$Selection = Read-Host
$mgmtippool = $Selection
Clear-Host

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
  
write-host -ForegroundColor Yellow -nonewline "
Select the number of the Portgroup Where You Would Like To Deploy the HCX Connector."
write-host -foregroundcolor yellow "This is typically the same portgroup which is used for other management type of workloads, but could be any portgroup you like.: "
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
  
write-host -ForegroundColor Yellow -nonewline "
Select the datastore where the HCX Connector and other HCX appliances should be deployed (not a significant amount of space required): "
$Selection = Read-Host
$Datastore = $items["$Selection"].Name
Clear-Host           



#######################################################################################
  #Define the HCX Connector Deployment Details
#######################################################################################
  write-Host -foregroundcolor Yellow -nonewline "You will now be asked to input the parameters for the HCX Connector OVA Deployment.  Remember the portgroup where it will be deployed is $VMNetwork
Press Any Key To Continue: "
  $Selection = Read-Host 
  
  write-host -ForegroundColor Yellow -nonewline "IP Address for the HCX Connector: "
  $Selection = Read-Host
  $HCXVMIP = $Selection
  
  write-host -ForegroundColor Yellow -nonewline "Netmask (in /xx format ... DO NOT INCLUDE the / ) for the HCX Connector: "
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
    write-Host -ForegroundColor Red $warning
    write-host -ForegroundColor Yellow -nonewline "Provide a admin password of your choice for the HCX Connector: "
    $Selection1 = Read-Host -MaskInput
    write-host -ForegroundColor Yellow -nonewline "
Enter the password again to validate: "
    $Selection2 = Read-Host -MaskInput
    $warning = "
The Passwords Which Were Entered Do Not Match"
    
    if ($Selection1 -eq $Selection2 ) {      
      $hcxadminpasswordvalidate = "samepassword"
    }
  }
  $HCXOnPremPassword = $Selection1


  write-host -ForegroundColor Yellow -nonewline "What is the nearest major city to where the HCX Connector is being deployed (example: New York, London, Miami, Melbourne, etc..): "
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
  write-host -ForegroundColor Yellow -nonewline "Provide password for your HCX Cloud Connector (It's the same password as your CLOUD vCenter): "
  $Selection1 = Read-Host -MaskInput
  write-host -ForegroundColor Yellow -nonewline "
Enter the password again to validate: "
  $Selection2 = Read-Host -MaskInput
  $warning = "
The Passwords Which Were Entered Do Not Match"
  
  if ($Selection1 -eq $Selection2 ) {      
    $hcxcloudpasswordvalidate = "samepassword"
  }
}
$HCXCloudPassword = $Selection1

write-host -ForegroundColor Yellow -nonewline "Enter a HCX Activiation Key: "
$Selection = Read-Host
$hcxactivationkey = $Selection

  
     $HCXOnPremUserID = "admin"
     $HCXManagerVMName = "AVS-HCX-Connector"
     $mgmtnetworkprofilename = "Management"
     $vmotionnetworkprofilename = "vMotion"
     $hcxactivationurl = "https://connect.hcx.vmware.com"
     $HCXCloudUserID = "cloudadmin@vsphere.local"
     $hcxComputeProfileName = "AVS-ComputeProfile"
     $hcxServiceMeshName = "AVS-ServiceMesh"
     
  
  mkdir $env:TEMP\AVSDeploy
  Clear-Host
  
  write-Host -foregroundcolor Yellow "Downloading VMware HCX Connector ... "
  $hcxfilename = "VMware-HCX-Connector-4.3.0.0-19068550.ova"
  #remove
  #Invoke-WebRequest -Uri https://avsdesignpowerapp.blob.core.windows.net/downloads/$hcxfilename -OutFile $env:TEMP\AVSDeploy\$hcxfilename
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
  #$vm = Import-VApp -Source $HCXApplianceOVA -OvfConfiguration $ovfconfig -Name $HCXManagerVMName -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin
  Import-VApp -Source $HCXApplianceOVA -OvfConfiguration $ovfconfig -Name $HCXManagerVMName -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin
  Write-Host -ForegroundColor Green "Success: HCX Connector Deployed to On-Premises Cluster"
  
  <###
  
  #########################
  # Only do this for internal testing
  #########################
  
  $HCXVMIP = "192.168.89.152"
  ###>
  
  #########################
  # Wait for PowerOn
  #########################
  
  # Power On the HCX Connector VM after deployment
  Write-Host -ForegroundColor Yellow "Powering on HCX Connector ..."
  Start-VM -VM $HCXManagerVMName -Confirm:$false
#  $vm | Start-VM -VM $HCXManagerVMName -Confirm:$false
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
  #$managementNetworkProfile = Get-HCXNetworkProfile -Name $mgmtnetworkprofilename
  #$vmotionNetworkProfile = Get-HCXNetworkProfile -Name $vmotionnetworkprofilename
  
  
  $managementNetworkProfile = Get-HCXNetworkProfile -Name $mgmtnetworkprofilename
  $vmotionNetworkProfile = Get-HCXNetworkProfile -Name $vmotionnetworkprofilename
  $hcxComputeCluster = Get-HCXApplianceCompute -ClusterComputeResource
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
  
  
  
  ###############
  #Exit
  ##########
  
  write-host -ForegroundColor Yellow -nonewline "
  HCX Is Now Deployed In Your On Premises Cluster, 
  Log into your On-Premises vCenter and You Should See a HCX Plug-In,
  If You Do Not, Log Out of vCenter and Log Back In.

  Press Any Key To Continue
  "
  $Selection = Read-Host
  Start-Process "https://$OnPremVIServerIP"
    }
    