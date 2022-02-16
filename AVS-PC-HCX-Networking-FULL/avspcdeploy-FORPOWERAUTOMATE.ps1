$internaltest="yes" #put yes if this is an internal test
$InternalAuthKey = "14eddea1-2f61-49d1-8a03-6bf2a9ae7779"
$InternalPeerURI = "/subscriptions/52d4e37e-0e56-4016-98de-fe023475b435/resourceGroups/tnt15-cust-p01-australiaeast/providers/Microsoft.Network/expressRouteCircuits/tnt15-cust-p01-australiaeast-er"



##avspcdeploy-variables.ps1
$sub = "1178f22f-6ce4-45e3-bd92-ba89930be5be"
$regionfordeployment = "southeastasia"
$RGNewOrExisting = "New" #RGforAVSNewOrExisting

if("New" -eq $RGNewOrExisting)
{
$rgfordeployment = "AVS1-VirtualWorkloads-APAC-AzureCloud-RG"
}
else {
$rgfordeployment = "" #rgfordeployment
}
$pcname = "AVS2-VirtualWorkloads-APAC-AzureCloud"
$skus = "AV36"
$addressblock = "10.1.0.0/22"
$ExrGatewayForAVS = "ExRGW-VirtualWorkloads-APAC-Hub" ##existingvnetgwname

$SameSubAVSAndExRGW = "No"
if ("Yes" -eq $SameSubAVSAndExRGW) {
$OnPremExRCircuitSub = $sub
}
else {
    $OnPremExRCircuitSub = "REPLACE-EXPRESSROUTESUB"
}

$ExrGWforAVSResourceGroup = "REPLACE-RGFORONPREMEXR"
$NameOfOnPremExRCircuit = "MyOnPremExR" 
$ExrForAVSRegion = "eastasia" 
$RGofOnPremExRCircuit = "REPLACE-RGFORONPREMEXR"  
$internet = "Enabled"
$numberofhosts = "3"

<#
#############################################################################################################
remove-item $env:TEMP\AVSDeploy\*.*
mkdir $env:TEMP\AVSDeploy
Clear-Host

#######################################################################################
# Check for Installs
#######################################################################################
if ($PSVersionTable.PSVersion.Major -lt 7){
    Write-Host -ForegroundColor Yellow "Upgrading Powershell..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
    Write-Host -ForegroundColor Green "Success: PowerShell Upgraded"
  }
  
$vmwareazcheck = Find-Module -Name Az.VMware
if ($vmwareazcheck.Name -ne "Az.VMware") {
  Write-Host -ForegroundColor Yellow "Installing Azure Powershell Module ..."
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Install-Module -Name Az -Repository PSGallery -Force
  Write-Host -ForegroundColor Green "Success: Azure Powershell Module Installed"
}


$vmwarepowerclicheck = Find-Module -Name VMware.PowerCLI
if ($vmwarepowerclicheck.Name -ne "VMware.PowerCLI") {
  Write-Host -ForegroundColor Yellow "Installing VMware.PowerCLI Module..."
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Install-Module -Name VMware.PowerCLI -Force
  Write-Host -ForegroundColor Green "Success: VMware.PowerCLI Module Installed"
}
  


$vmwarepowerclicheck = Find-Module -Name VMware.VimAutomation.Hcx
if ($vmwarepowerclicheck.Name -ne "VMware.VimAutomation.Hcx") {
  Write-Host -ForegroundColor Yellow "VMware.VimAutomation.Hcx Module..."
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Install-Module -Name VMware.VimAutomation.Hcx -Force
  Write-Host -ForegroundColor Green "Success: VMware.VimAutomation.Hcx Module Installed"
}
  



Write-Host -ForegroundColor Yellow "
Is Azure CLI Installed On This Machine? (Y/N)
"

$azurecliyesorno = Read-Host
if ("n" -eq $azurecliyesorno) {
    Write-Host -ForegroundColor Red "The Azure CLI Installer Will Download and Auto Install, After The Installation You MUST Reboot Your Computer"
    Write-Host -ForegroundColor Yellow "Would You Like To Install Azure CLI? (Y/N)"
    $begin = Read-Host

    if ("y" -eq $begin ) {
     Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile $env:TEMP\AVSDeploy\AzureCLI.msi
      Set-Location $env:TEMP\AVSDeploy\
      Start-Process -Wait "$env:TEMP\AVSDeploy\AzureCLI.msi"
      Write-Host -ForegroundColor Green "Azure CLI Installed"
    }
    Exit-PSSession

  }
    
#>
#connecttoazure.ps1
write-host -ForegroundColor Yellow "
Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
Connect-AzAccount -Subscription $sub
write-host -ForegroundColor Green "
Azure Login Successful
"
#validatesubready.ps1

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

Start-Sleep 5
}


Else

{
Write-Host -ForegroundColor Red "
Subscription $sub Does NOT Have Quota for Azure VMware Solution, please visit the following site for guidance on how to get this service enabled for your subscription.

https://docs.microsoft.com/en-us/azure/azure-vmware/enable-azure-vmware-solution"

Exit

}
<#
#DefineResourceGroup.ps1
if ( "Existing" -eq $RGNewOrExisting )
{
    write-host -foregroundcolor Green = "
AVS Private Cloud Resource Group is $rgfordeployment
"
}

if ( "New" -eq $RGNewOrExisting){
    New-AzResourceGroup -Name $rgfordeployment -Location $regionfordeployment

    write-host -foregroundcolor Green = "
Success: AVS Private Cloud Resource Group $rgfordeployment Created
"   

}

#kickoffdeploymentofavsprivatecloud.ps1


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


#ConnectAVSExrToVnet.ps1

$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment
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
#>
#ConnectAVSExrToOnPremExr.ps1


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
  
  #addhcx.ps1
  $deployhcxyesorno = "No"

if ($deployhcxyesorno -eq "Yes") {

write-Host -ForegroundColor Yellow "Deploying VMware HCX to the $pcname Private Cloud ... This will take approximately 45 minutes ... "
az vmware addon hcx create --resource-group "" --private-cloud "AVS2-VirtualWorkloads-APAC-AzureCloud" --offer "VMware MaaS Cloud Provider"
write-Host -ForegroundColor Green "Success: VMware HCX has been deployed to $pcname Private Cloud"


######################################################

#######################################################################################
# Check for Installs
#######################################################################################
if ($PSVersionTable.PSVersion.Major -lt 7){
  Write-Host -ForegroundColor Red "Please upgrade Powershell to 7.x"
  Exit-PSSession
}

$vmwarepowerclicheck = Find-Module -Name VMware.PowerCLI
if ($vmwarepowerclicheck.Name -ne "VMware.PowerCLI") {
  Write-Host -ForegroundColor Red "Please install the VMware.PowerCLI Module"
  Exit-PSSession
  
}

$vmwarepowerclicheck = Find-Module -Name VMware.VimAutomation.Hcx
if ($vmwarepowerclicheck.Name -ne "VMware.VimAutomation.Hcx") {
  Write-Host -ForegroundColor Red "Please install the VMware.VimAutomation.Hcx Module"
  Exit-PSSession
  }

###########################
# Get the variables
###########################

   $OnPremVIServerIP = "10.17.0.2"
   $PSCSameAsvCenterYesOrNo = "Yes"
if ($PSCSameAsvCenterYesOrNo -eq "Yes" ) {
     $PSCIP = $OnPremVIServerIP
   }



#Get Cluster Name
write-host -ForegroundColor Red "You will be prompted to log into you on-premises vCenter Server $OnPremVIServerIP..."
Connect-VIServer -Server 10.17.0.2
write-host -foregroundcolor blue "=================================
"

   $clusters = Get-Cluster 
      $Count = 0
      
       foreach ($cluster in $clusters) {
          $clusterlist = $cluster.Name
          Write-Host "$Count - $clusterlist"
          $Count++
       }
       
write-host -foregroundcolor blue "
=================================  "
       
$OnPremCluster = Read-Host "
Select the number which corresponds to the Cluster where you would like to deploy the HCX Connector.

Generally pick the one which has the VMs you are going to be migrating, but could be any cluster managed by this vCenter"
$OnPremCluster = $clusters["$OnPremCluster"].Name


#Pick L2 Extension DVS

write-host -foregroundcolor Yellow "
=================================  "
       
$Selection = Read-Host "
Are you extending L2 VDS portgroups to AVS? (Y/N)"
if ($Selection =eq "y") {
  write-host -foregroundcolor blue "=================================
  "
  
     $item = Get-VDSwitch 
        $Count = 0
        
         foreach ($item in $items) {
            $list = $item.Name
            Write-Host "$Count - $list"
            $Count++
         }
         
  write-host -foregroundcolor blue "
  =================================  "
         
  $Selection = Read-Host "
  Select the switch from this list which contgains the portgroups which will be extended to AVS."
  $hcxVDS = $items["$Selection"].Name
  
  
}


#Pick the network segments

write-host -foregroundcolor blue "=================================
  "
  
     $item = Get-VirtualNetwork
        $Count = 0
        
         foreach ($item in $items) {
            $list = $item.Name
            Write-Host "$Count - $list"
            $Count++
         }
         
  write-host -foregroundcolor blue "
  =================================  "
         
$Selection = Read-Host "
Select the number of the portgroup which cooresponds to your VMOTION network"
$vmotionportgroup = $items["$Selection"].Name

$Selection = Read-Host "
What is the Gateway for the vMotion Network on porgroup $vmotionportgroup ? : "
$vmotionprofilegateway = $Selection

Write-Host "
What is the Netmask for the vMotion Network (in this format /xx) on porgroup $vmotionportgroup ?" 
$Selection = Read-Host "/"
$vmotionnetworkmask = $Selection

$Selection = Read-Host "
Provide three FREE IP Addresses on the vMotion Network Segment (in this format ... x.x.x.x-x.x.x.x):" 
$vmotionippool = $Selection

$Selection = Read-Host "
Select the number of the portgroup which cooresponds to your MANAGEMENT network"
$managementportgroup = $items["$Selection"].Name

$Selection = Read-Host "
What is the Gateway for the Management Network on portgroup $managementportgroup ? : "
$mgmtprofilegateway = $Selection

Write-Host "
What is the Netmask for the Management Network (in this format /xx) on porgroup $managementportgroup ?" 
$Selection = Read-Host "/"
$mgmtnetworkmask = $Selection

$Selection = Read-Host "
Provide three FREE IP Addresses on the Management Network Segment (in this format ... x.x.x.x-x.x.x.x):" 
$mgmtippool = $Selection


$Selection = Read-Host "
Select the portgroup where the HCX Connector should be deployed.
This is typically the same portgroup which is used for other management type of workloads, but could be any portgroup you like."
$VMNetwork = $items["$Selection"].Name

#Pick the Datastore to use

write-host -foregroundcolor blue "=================================
  "
  
     $item = Get-Datastore
        $Count = 0
        
         foreach ($item in $items) {
            $list = $item.Name
            Write-Host "$Count - $list"
            $Count++
         }
         
  write-host -foregroundcolor blue "
  =================================  "
         
$Selection = Read-Host "
Select the datastore where the HCX Connector and other HCX appliances should be deployed (not a significant amount of space required)."
$Datastore = $items["$Selection"].Name


#Define the HCX Connector Deployment Details
write-Host -foregroundcolor Yellow "You will now be asked to input the parameters for the HCX Connector OVA Deployment.  Remember the portgroup where it will be deployed is $VMNetwork"
$Selection = Read-Host -ForegroundColor "Press Any Key To Continue"

$Selection = Read-Host "
IP Address for the HCX Connector:"
$HCXVMIP = $Selection

$Selection = Read-Host "
Netmask (in /xx format) for the HCX Connector:"
$HCXVMNetmask = $Selection

$Selection = Read-Host "
Gateway for the HCX Connector:"
$HCXVMGateway = $Selection

$Selection = Read-Host "
Domain for the HCX Connector (example: mycompany.com):"
$HCXVMDomain = $Selection

$Selection = Read-Host "
NTP Server for the HCX Connector (example: pool.ntp.com):"
$AVSVMNTP = $Selection

$Selection = Read-Host "
Provide a admin password of your choice for the HCX Connector:"
$HCXOnPremPassword = $Selection

$Selection = Read-Host "
What is the nearest major city to where the HCX Connector is being deployed (example: New York, London, Miami, Melbourne, etc..):"
$HCXOnPremLocation = "$Selection"


   
   $HCXCloudIP = ""
   $HCXCloudPassword = ""

   $HCXOnPremRoleMapping = ""
   $hcxactivationkey = ""

   $HCXOnPremUserID = "admin"
   $HCXManagerVMName = "AVS-HCX-Connector"
   $mgmtnetworkprofilename = "Management"
   $vmotionnetworkprofilename = "vMotion"
   $hcxactivationurl = "https://connect.hcx.vmware.com"
   $HCXCloudUserID = "cloudadmin@vsphere.local"
   $hcxComputeProfileName = "AVS-ComputeProfile"
   $hcxServiceMeshName = "AVS-ServiceMesh"
   $hcxRemoteComputeProfileName = "TNT43-HCX-COMPUTE-PROFILE"
   
write-Host -foregroundcolor Yellow "Downloading VMware HCX Connector ... "
$hcxfilename = "VMware-HCX-Connector-4.3.0.0-19068550.ova"
Invoke-WebRequest -Uri https://avsdesignpowerapp.blob.core.windows.net/downloads/$filename -OutFile $env:TEMP\AVSDeploy\$hcxfilename
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
$vm = Import-VApp -Source $HCXApplianceOVA -OvfConfiguration $ovfconfig -Name $HCXManagerVMName -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin
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
$vm | Start-VM -Confirm:$false | Out-Null
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
# Create vMotion Netowrk Profile
######################

$vmotionnetworkbacking = Get-HCXNetworkBacking -Server $HCXVMIP -Name $vmotionportgroup 

$command = New-HCXNetworkProfile -PrimaryDNS "$HCXVMDNS" -DNSSuffix "$HCXOnPremRoleMapping" -Name "$vmotionnetworkprofilename" -GatewayAddress "$vmotionprofilegateway" -IPPool "$vmotionippool" -Network $vmotionnetworkbacking -PrefixLength "$vmotionnetworkmask"
$command | ConvertTo-Json


######################
# Create Management Netowrk Profile
######################




$mgmtnetworkbacking = Get-HCXNetworkBacking -Server $HCXVMIP -Name $managementportgroup 

$command = New-HCXNetworkProfile -PrimaryDNS "$HCXVMDNS" -DNSSuffix "$HCXOnPremRoleMapping" -Name "$mgmtnetworkprofilename" -GatewayAddress "$mgmtprofilegateway" -IPPool "$mgmtippool" -Network $mgmtnetworkbacking -PrefixLength "$mgmtnetworkmask"
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
$hcxRemoteComputeProfile = Get-HCXComputeProfile -Site $hcxDestinationSite -Name $hcxRemoteComputeProfileName

$command = New-HCXServiceMesh -Name $hcxServiceMeshName -SourceComputeProfile $hcxLocalComputeProfile -Destination $hcxDestinationSite -DestinationComputeProfile $hcxRemoteComputeProfile -Service BulkMigration,Interconnect,Vmotion,WANOptimization,NetworkExtension 
$command | ConvertTo-Json

###############
#Exit
##########

Write-Host -ForegroundColor Green "
HCX Is Now Deployed In Your On Premises Cluster, 
Log into your On-Premises vCenter and You Should See a HCX Plug-In,
If You Do Not, Log Out of vCenter and Log Back In.
"
Write-Host -ForegroundColor White "Press Any Key To Continue"


Start-Process "https://$OnPremVIServerIP"
}