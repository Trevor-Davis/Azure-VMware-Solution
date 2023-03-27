# Author: Trevor Davis
# Website: www.virtualworkloads.com
# Twitter: vTrevorDavis
# This script can be used to deploy HCX to an on-prem location and fully connect and configure for use w/ an AVS Private Cloud
# For guidance on this script please refer to https://www.virtualworkloads.com 
# 0.92
 

#variables

$appliancefiledirectory = "c:\windows\temp\hcxappliance"
. $appliancefiledirectory\hcxappliancevariables.ps1

#DO NOT MODIFY BELOW THIS LINE #################################################
$ProgressPreference = 'SilentlyContinue'
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$hcxovafilename = "VMware-HCX-Connector-4.5.0.0-20616025.ova"

$HCXManagerVMName = "HCX-Manager"
$HCXOnPremAdminUserID = "admin"
$HCXCloudUserID = "cloudadmin@vsphere.local"
$mgmtnetworkprofilename = "HCXNetworkProfile"
$hcxComputeProfileName = "HCXComputeProfile"
$hcxServiceMeshName = "HCXServiceMesh"
$logfilename = "hcxonpreminstall.log"

#Azure Login
$filename = "Function-azurelogin.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$filename

azurelogin -subtoconnect $sub

#Start Logging
Start-Transcript -Path $env:TEMP\$logfilename -Append

#Execution ###########################################################################

Write-Host -foregroundcolor Yellow "
Deploying HCX Manager to vCenter $OnPremVIServerIP and Connecting to $pcname"

#######################################################################################
# Connect to On-Prem vCenter
#######################################################################################  
Write-Host -ForegroundColor Yellow "
Connecting to On-Premises vCenter"

$test = Get-VIServer -Server $OnPremVIServerIP -username $OnPremVIServerUsername -password $OnPremVIServerPassword

if ($test.Name -eq $OnPremVIServerIP) {
write-Host -ForegroundColor Blue "
vCenter $OnPremVIServerIP Connected"
}
else {
write-host -foregroundcolor Yellow "
Connecting to $OnPremVIServerIP"

$command = Connect-VIServer -Server $OnPremVIServerIP -username $OnPremVIServerUsername -password $OnPremVIServerPassword


$test = Get-VIServer -Server $OnPremVIServerIP -username $OnPremVIServerUsername -password $OnPremVIServerPassword
if ($test.Name -ne $OnPremVIServerIP){
Write-Host -ForegroundColor Red "
Connecting to vCenter $OnPremVIServerIP Failed"
Exit
}
$command
write-Host -ForegroundColor Blue "
vCenter $OnPremVIServerIP Connected"
}



#######################################################################################
# Install HCX To Private Cloud
#######################################################################################

$test = Get-AzVMwareAddon -PrivateCloudName $pcname -ResourceGroupName $pcrg -AddonType hcx 

if ($test.Name -eq "hcx") {
write-Host -ForegroundColor Blue "
HCX is Enabled on $pcname"
}
else {
write-host -foregroundcolor Yellow "
Deploying VMware HCX to the $pcname Private Cloud ... This will take approximately 30 minutes ... "

$command = az vmware addon hcx create --resource-group $pcrg --private-cloud $pcname --offer "VMware MaaS Cloud Provider (Enterprise)"

$test = az vmware addon hcx show --resource-group $pcrg --private-cloud $pcname
if ($test.Name -ne "hcx"){
Write-Host -ForegroundColor Red "
HCX deployment to $pcname failed"
Exit
}
$command
write-Host -ForegroundColor Blue "
HCX Deployed to $pcname"
}

#######################################################################################
#Get HCX Cloud IP Address and Password
#######################################################################################

#IP Address
  $myprivatecloud = Get-AzVMwarePrivateCloud -Name $pcname -ResourceGroupName $pcrg -Subscription $sub
    $HCXCloudURL = $myprivatecloud.EndpointHcxCloudManager
  $length = $HCXCloudURL.length 
  $HCXCloudIP = $HCXCloudURL.Substring(8,$length-9)

#Password

$command = Get-AzVMwarePrivateCloudAdminCredential -PrivateCloudName $pcname -ResourceGroupName $pcrg
$HCXCloudPassword = ConvertFrom-SecureString -SecureString $command.VcenterPassword -AsPlainText
 

#######################################################################################
#Get HCX Activation Key
#######################################################################################
write-host -foregroundcolor Yellow -nonewline "

You can create a HCX Activation Key in the Azure Portal by navigating to the following location.  
Select your PRIVATE CLOUD > MANAGE > ADD-ONs > MIGRATION USING HCX

Or 

You can skip this step and enter an activation key at a later time.  HCX will run in trial mode for the next 30 days.

Would you like to enter an activation key now? (Y/N): "

$Selection = Read-Host
if ($selection -eq "Y")
{
write-host -ForegroundColor Yellow -nonewline "Enter a HCX Activation Key: "
$hcxactivationkey = Read-Host
}

#######################################################################################
#Deploy HCX OVA On-Prem
#######################################################################################

$status = Get-VM -Name $HCXManagerVMName -erroraction:silentlycontinue
if ($status.count -ne 1){
  
  
  
#define the OVA
#Assumption is the OVA is in teh same directory as this powershell script

$mypath = $MyInvocation.MyCommand.Path 
$mypath = split-path $mypath -Parent
Set-Location -Path $mypath

# $HCXApplianceOVA = $mypath+"\"+$hcxovafilename
 
  # Load OVF/OVA configuration into a variable
  $ovfconfig = Get-OvfConfiguration $hcxovafilename
  $ovfconfig
  $Cluster = Get-Cluster $OnPremCluster | Get-VMHost
 
  # vSphere Portgroup Network Mapping
  $ovfconfig.NetworkMapping.VSMgmt.value = $VMNetwork
  $ovfConfig.common.mgr_ip_0.value = $HCXVMIP
  $ovfConfig.common.mgr_prefix_ip_0.value = $HCXVMNetmask
  $ovfConfig.common.mgr_gateway_0.value = $HCXVMGateway
  $ovfConfig.common.mgr_dns_list.value = $HCXVMDNS
  $ovfConfig.common.mgr_domain_search_list.value  = $HCXVMDomain
  $ovfconfig.Common.hostname.Value = $HCXManagerVMName
  $ovfconfig.Common.mgr_ntp_list.Value = $AVSVMNTP
  $ovfconfig.Common.mgr_isSSHEnabled.Value = $true
  $ovfconfig.Common.mgr_cli_passwd.Value = $HCXOnPremAdminPassword
  $ovfconfig.Common.mgr_root_passwd.Value = $HCXOnPremAdminPassword
  $ovfconfig.Common.mgr_isSSHEnabled.Value = $true
  $ovfconfig.Common.mgr_cli_passwd.Value = $HCXOnPremAdminPassword
  $ovfconfig.Common.mgr_root_passwd.Value = $HCXOnPremAdminPassword 
  
  
  # Deploy the OVF/OVA with the config parameters
  Write-Host -ForegroundColor Yellow "
Deploying HCX Connector OVA ... This could take a bit ... You should be able to see the progress of the OVA being imported into your on-prem vCenter"
 
  $requestvcenter = Invoke-WebRequest -Uri "https://$($OnPremVIServerIP):443" -Method GET -SkipCertificateCheck -TimeoutSec 5

  if ($requestvcenter.StatusCode -ne 200) {
write-Host -ForegroundColor Red "The machine this script is running from cannot reach the vCenter Server on port 443, please resolve this issue and re-run the script."
Exit
  }

  $requesthost = Test-Connection -IPv4 -TcpPort 902 $Cluster[0]
  if ($requesthost -ne "True") {
write-Host -ForegroundColor Red "
The machine this script is running from cannot reach the VMware environment on port 902 to deploy the OVA, please resolve this issue and re-run the script."
Exit
  }

Import-VApp -Source $hcxovafilename -OvfConfiguration $ovfconfig -Name $HCXManagerVMName -VMHost $Cluster[0] -Datastore $datastore -DiskStorageFormat thin

$status = Get-VM -Name $HCXManagerVMName
if ($status.PowerState -ne "PoweredOff"){
Write-Host -ForegroundColor Red "
HCX OVA Deployment Failed"
Exit
}
else {
  Write-Host -ForegroundColor Green "
Success: HCX Manager OVA Imported"
}
}
 
 
  #########################
  # PowerOn HCX Manager
  #########################

  $status = Get-VM -Name $HCXManagerVMName
  if ($status.PowerState -eq "PoweredOn"){
  Write-Host -ForegroundColor Green "
HCX Manager is PoweredOn"

}
  
  if ($status.PowerState -ne "PoweredOn") {

  Write-Host -ForegroundColor Yellow "
Powering on HCX Manager ..."
  Start-VM -VM $HCXManagerVMName -Confirm:$false

  while($status.PowerState -ne "PoweredOn")
  {

Start-Sleep -Seconds 30
$status = Get-VM -Name $HCXManagerVMName
}

Write-Host -ForegroundColor Green "
HCX Manager is PoweredOn"

  }

# Waiting for HCX Connector to initialize
  while(1) {
    try {

         $requests = Invoke-WebRequest -Uri "https://$($HCXVMIP):9443" -Method GET -SkipCertificateCheck -TimeoutSec 5
         
        if($requests.StatusCode -eq 200) {
            Write-Host -ForegroundColor Green "
Success: HCX Manager is now ready to be configured!"
            break
        }
    }
    catch {
        Write-Host -ForegroundColor Yellow "
HCX Manager Still Getting Ready ... Will Check Again In 30 Seconds ..."
        Start-Sleep 30
    }
}


  #########################################
  # Encode the HCX On Prem Admin credentials
  #########################################
  
  $HCXOnPremCredentials = "$HCXOnPremAdminUserID"+":"+"$HCXOnPremAdminPassword" 
  $HCXBytes = [System.Text.Encoding]::UTF8.GetBytes($HCXOnPremCredentials)
  $HCXOnPremAdminCredentialsEncoded =[Convert]::ToBase64String($HCXBytes)


       
    
  ######################################
  # Get The Certificate From HCX Cloud
  ####################################
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Accept", "application/json")
  $headers.Add("Authorization", "Basic $HCXOnPremAdminCredentialsEncoded")
  
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
  $headers.Add("Authorization", "Basic $HCXOnPremAdminCredentialsEncoded")
  
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
  $headers.Add("Authorization", "Basic $HCXOnPremAdminCredentialsEncoded")
  
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
  $headers.Add("Authorization", "Basic $HCXOnPremAdminCredentialsEncoded")
  
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



  ###############################
  ## login to HCX Connector and get the session info / Certificate for future API Call
  ###################################
  
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Accept", "application/json")
  $headers.Add("Authorization", "Basic $HCXOnPremAdminCredentialsEncoded")

  
  $body = "{
         `"username`": `"$OnPremVIServerUsername`",
         `"password`": `"$OnPremVIServerPassword`"
     }"
  ##This username and password combination is used because it's the same as the on-prem vcenter
  
  
  $response = Invoke-RestMethod https://$($HCXVMIP)/hybridity/api/sessions -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck -SessionVariable 'Session'
  $response | ConvertTo-Json
  $session
  
  #########################
  # Retrieve Location 
  #########################
  
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Accept", "application/json")
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Authorization", "Basic $HCXOnPremAdminCredentialsEncoded")
  
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
  if ($null -eq $hcxactivationkey) {
    Write-Host -ForegroundColor Red "You did not enter an HCX Activation Key, HCX will be deployed in evaluation mode."
    
   }
   else {
    
  
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Accept", "application/json")
  $headers.Add("Content-Type", "application/json")
  $headers.Add("Authorization", "Basic $HCXOnPremAdminCredentialsEncoded")
  
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
  ######################################
  # Connect To On Prem HCX Server
  ######################################
  $connecthcx = Connect-HCXServer -Server $HCXVMIP -User $OnPremVIServerUsername -Password $OnPremVIServerPassword 
  while ($connecthcx.IsConnected -ne "True" ) {
    Write-Host -ForegroundColor yellow 'Waiting for On-Premises HCX Connector Services To Re-Start ... Checking Again In 1 Minute ....'
    Start-Sleep -Seconds 60
    $connecthcx = Connect-HCXServer -Server $HCXVMIP -User $OnPremVIServerUsername -Password $OnPremVIServerPassword 
  
  }
 
  
  ######################
# Site Pairing
######################

$request = Invoke-WebRequest -Uri "https://$($HCXCloudIP)" -Method GET -SkipCertificateCheck -TimeoutSec 5
         
if($request.StatusCode -ne 200) {
Write-Host -foregroundcolor Red "
It appears there is no network connectivity to $HCXCloudIP, cannot continue"
exit}

    $command = New-HCXSitePairing -Url https://$($HCXCloudIP) -Username $HCXCloudUserID -Password $HCXCloudPassword -Server $HCXVMIP
    $command | ConvertTo-Json
    $command

    
  ######################
  # Create Management Network Profile
  ######################
  
  
  $mgmtnetworkbacking = Get-HCXNetworkBacking -Server $HCXVMIP -Name $managementportgroup 
  
  $command = New-HCXNetworkProfile -PrimaryDNS $HCXVMDNS -DNSSuffix $HCXVMDomain -Name $mgmtnetworkprofilename -GatewayAddress $mgmtprofilegateway -IPPool $mgmtippool -Network $mgmtnetworkbacking -PrefixLength $mgmtnetworkmask
  $command | ConvertTo-Json
  
Write-Host "management network profile created on prem"  
Read-Host
  
  ######################
  # Create ComputeProfile
  ######################
  
  $managementNetworkProfile = Get-HCXNetworkProfile -Name $mgmtnetworkprofilename
  # $vmotionNetworkProfile = Get-HCXNetworkProfile -Name $vmotionnetworkprofilename
  $hcxComputeCluster = Get-HCXApplianceCompute -ClusterComputeResource -Name $OnPremCluster
  $hcxDatastore = Get-HCXApplianceDatastore -Compute $hcxComputeCluster -Name $datastore

  if ($null -ne $l2extendedVDS) {
    $l2extendedVDS = Get-HCXInventoryDVS -Name $l2extendedVDS
    $command = New-HCXComputeProfile `
    -Name $hcxComputeProfileName `
    -ManagementNetworkProfile $managementNetworkProfile `
    -vMotionNetworkProfile $managementNetworkProfile `
    -UplinkNetworkProfile $managementNetworkProfile `
    -vSphereReplicationNetworkProfile $managementNetworkProfile `
    -DistributedSwitch $l2extendedVDS `
    -Service BulkMigration,Interconnect,Vmotion,WANOptimization,NetworkExtension -Datastore $hcxDatastore -DeploymentResource $hcxComputeCluster -ServiceCluster $hcxComputeCluster


  }

  if ($null -eq $l2extendedVDS) {
    $command = New-HCXComputeProfile -Name $hcxComputeProfileName -ManagementNetworkProfile $managementNetworkProfile -vMotionNetworkProfile $managementNetworkProfile -Service BulkMigration,Interconnect,Vmotion,WANOptimization -Datastore $hcxDatastore -DeploymentResource $hcxComputeCluster -ServiceCluster $hcxComputeCluster -Server $HCXVMIP

  }

  $command | ConvertTo-Json
  
  
  Write-Host "created on prem compute profile"  
  Read-Host
     
  
  ###############
  #Service Mesh
  ###############
    
  $hcxDestinationSite = Get-HCXSite -Destination -ErrorAction Stop
  $hcxDestinationSite
  Write-Host "hcxdestinationsite"  
  Read-Host
     
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

  if ($null -ne $l2extendedVDS) {
    $command = New-HCXServiceMesh -Name $hcxServiceMeshName `
    -SourceComputeProfile $hcxLocalComputeProfile `
    -DestinationComputeProfile $hcxRemoteComputeProfile `
    -Destination $hcxDestinationSite `
    -SourceUplinkNetworkProfile $hcxSourceUplinkNetworkProfile `
    -DestinationUplinkNetworkProfile $remoteuplinknetworkprofile `
    -Service BulkMigration,Interconnect,Vmotion,WANOptimization,NetworkExtension -Server $HCXVMIP
    $command | ConvertTo-Json
  
  }

  if ($null -eq $l2extendedVDS) {
    $command = New-HCXServiceMesh -Name $hcxServiceMeshName `
    -SourceComputeProfile $hcxLocalComputeProfile `
    -DestinationComputeProfile $hcxRemoteComputeProfile `
    -Destination $hcxDestinationSite `
    -SourceUplinkNetworkProfile $hcxSourceUplinkNetworkProfile `
    -DestinationUplinkNetworkProfile $remoteuplinknetworkprofile `
    -Service BulkMigration,Interconnect,Vmotion,WANOptimization -Server $HCXVMIP
    $command | ConvertTo-Json
  
  }


$status = Get-HCXServiceMesh -Name $hcxServiceMeshName -Server $hcxvmip
while ($status.ServiceStatus.Count -eq 0){
Write-host -nonewline "Service Mesh Status: "
Write-Host -ForegroundColor Yellow "Preparing"
Start-Sleep -Seconds 60
$status = Get-HCXServiceMesh -Name $hcxServiceMeshName -Server $hcxvmip
}


$count = 0
$status = Get-HCXServiceMesh -Name $hcxServiceMeshName -Server $hcxvmip
while ($status.ServiceStatus.status.Contains("unknown") -eq "True"){
Write-host -nonewline "Service Mesh Status: "
Write-Host -ForegroundColor Yellow "Building"
Start-Sleep -Seconds 60
$status = Get-HCXServiceMesh -Name $hcxServiceMeshName -Server $hcxvmip
$count = $count +1
if ($count -eq 20) {
write-host -ForegroundColor Red "Service Mesh Build Has Timed Out"
exit
$status = Get-HCXServiceMesh -Name $hcxServiceMeshName -Server $hcxvmip
$status.ServiceStatus
}
}


$status = Get-HCXServiceMesh -Name $hcxServiceMeshName -Server $hcxvmip
if ($status.ServiceStatus.status.Contains("up") -eq "True"){

Write-host -nonewline "Service Mesh Status: "
Write-Host -ForegroundColor Green "Complete
"
}

Write-Host -ForegroundColor Yellow "
Press Any Key to Exit"
$status.ServiceStatus

Read-Host
Write-Host -ForegroundColor Yellow "Script Will Exit in 30 Seconds"
Start-Sleep -Seconds 30
