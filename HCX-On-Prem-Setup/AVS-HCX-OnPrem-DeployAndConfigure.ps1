#variables

$sub = "1178f22f-6ce4-45e3-bd92-ba89930be5be" #the sub where the AVS private cloud is deployed, use the ID not the name.
$pcname = "VirtualWorkloads-AVS-PC01" #Name of the AVS private cloud
$pcrg = "VirtualWorkloads-AVS-PC01" #The resource group where AVS private cloud is deployed.
$OnPremVIServerIP ="192.168.89.10" #This is the IP of the vCenter Server on-premises where HCX needs to be deployed.
$OnPremVIServerUsername = "administrator@vsphere.local" #This is the username of the vCenter Server on-premises where HCX needs to be deployed.
$OnPremVIServerPassword = "Microsoft1!" #password for username above.
$HCXOnPremPassword = "Microsoft1!" #When HCX is installed on-prem there will be a local user created called admin, provide the password you would like assigned to that user.
#$HCXApplianceOVA = "VMware-HCX-Connector-4.5.0.0-20616025.ova"
$OnPremCluster = "Cluster-VirtualWorkloads" #The name of teh cluster where HCX Appliance will be deployed.
$datastore = "iscsi" #the name of the datastore to deploy HCX Manager
$VMNetwork = "DPortGroup" #What network should HCX Manager be deployed ... must be the name of the portgroup in vCenter.
$HCXVMIP = "192.168.89.9" #The IP to assign to HCX Manager.
$HCXVMNetmask ="24" #netmask for the $vmnetwork
$HCXVMGateway = "192.168.89.1" #gateway for the for the $vmnetwork
$HCXVMDNS ="10.20.0.4" #DNS Server to use
$HCXVMDomain = "virtualworkloads.local" #domain to assign to HCX Manager
#$AVSVMNTP = "10.20.0.4" #NTP Server for HCX Manager
$HCXApplianceOVA = "C:\Users\avs-admin\Azure-VMware-Solution\HCX-On-Prem-Setup\VMware-HCX-Connector-4.5.0.0-20616025.ova"
$PSCIP = $OnPremVIServerIP #typically the platform services controller is the on-prem vcenter, if not change to the IP of the psc. 
$ssodomain = "vsphere.local"
$ssogroup = "Administrators"
$HCXOnPremLocation = "Buffalo"

#DO NOT MODIFY BELOW THIS LINE #################################################
$ProgressPreference = 'SilentlyContinue'

$HCXManagerVMName = "HCX-Manager-for-$pcname"
$HCXOnPremUserID = "admin"
$HCXCloudUserID = "cloudadmin@vsphere.local"

#Azure Login

$filename = "Function-azurelogin.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$filename

  azurelogin -subtoconnect $sub

#Start Logging
Start-Transcript -Path $env:TEMP\$folderforstaging\$logfilename".log" -Append


#Execution

#Clear-Host
Write-Host -ForegroundColor Magenta "Deploying HCX"



#######################################################################################
# Connect to On-Prem vCenter
#######################################################################################  

<#
write-host -ForegroundColor Yellow "What is the USERNAME and PASSWORD for the ON-PREMISES vCenter Server ($OnPremVIServerIP) where the VMware HCX Connector will be deployed?"
write-host -ForegroundColor White -nonewline "Username: "
$OnPremVIServerUsername = Read-Host 
write-host -ForegroundColor White -nonewline "Password: "
$OnPremVIServerPassword = Read-Host -MaskInput
#>


Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer -Server $OnPremVIServerIP -username $OnPremVIServerUsername -password $OnPremVIServerPassword



#######################################################################################
# Install HCX To Private Cloud
#######################################################################################
<#
   $status = Get-AzVMwareAddon -PrivateCloudName $pcname -ResourceGroupName $pcrg -AddonType hcx -ErrorAction Ignore
   if ($status.name -eq "hcx") {
    $hcxdeployed = 1
    write-Host -ForegroundColor Blue "
HCX Has Already Been Deployed to $pcname Private Cloud"
  }


if ($hcxdeployed -eq 0) {
  az login
  az config set extension.use_dynamic_install=yes_without_prompt
  az account set --subscription $sub
  
  write-Host -ForegroundColor Yellow "Deploying VMware HCX to the $pcname Private Cloud ... This will take approximately 30 minutes ... "
 az vmware addon hcx create --resource-group $pcrg --private-cloud $pcname --offer "VMware MaaS Cloud Provider"
  write-Host -ForegroundColor Green "Success: VMware HCX has been deployed to $pcname Private Cloud"
   
}

#>

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
write-host -ForegroundColor Yellow -nonewline "Enter a HCX Activation Key
You can create a HCX Activation Key in the Azure Portal.  
Select your PRIVATE CLOUD > MANAGE > ADD-ONs > MIGRATION USING HCX
Activation Key: "
$Selection = Read-Host
$hcxactivationkey = $Selection

#######################################################################################
#Deploy HCX OVA On-Prem
#######################################################################################
  
 <# 
  #download the HCX OVA
  $ProgressPreference = 'SilentlyContinue'
  $hcxfilename = "VMware-HCX-Connector-4.5.0.0-20616025.ova"

  $checkhcxfilesize = Get-Item $env:TEMP\$hcxfilename -ErrorAction:Ignore
  
    if ($checkhcxfilesize.Length/1gb -ne "5.08445739746094")
  {
    write-Host -foregroundcolor Yellow "
Downloading VMware HCX Connector ... "
    Invoke-WebRequest -Uri https://avsdesignpowerapp.blob.core.windows.net/downloads/$hcxfilename -OutFile $env:TEMP\$hcxfilename
    
    write-Host -foregroundcolor Green "
Success: VMware HCX Connector Downloaded"
  }

  #>
 
  # Load OVF/OVA configuration into a variable
  $ovfconfig = Get-OvfConfiguration $HCXApplianceOVA
  #$ovfconfig = Get-OvfConfiguration .\$HCXApplianceOVA
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
  $ovfconfig.Common.mgr_cli_passwd.Value = $HCXOnPremPassword
  $ovfconfig.Common.mgr_root_passwd.Value = $HCXOnPremPassword
  $ovfconfig.Common.mgr_isSSHEnabled.Value = $true
  $ovfconfig.Common.mgr_cli_passwd.Value = $HCXOnPremPassword
  $ovfconfig.Common.mgr_root_passwd.Value = $HCXOnPremPassword
  

  # Deploy the OVF/OVA with the config parameters
  Write-Host -ForegroundColor Yellow "Deploying HCX Connector OVA ... This could take a bit ... You should be able to see the progress of the OVA being imported into your on-prem vCenter"
 
  $requestvcenter = Invoke-WebRequest -Uri "https://$($OnPremVIServerIP):443" -Method GET -SkipCertificateCheck -TimeoutSec 5
  if ($requestvcenter.StatusCode -ne 200) {
write-Host -ForegroundColor Red "The machine this script is running from cannot reach the vCenter Server on port 443, please resolve this issue and re-run the script."
Exit
  }

  $requesthost = Test-Connection -IPv4 -TcpPort 902 $Cluster[0]
  if ($requesthost -ne "True") {
write-Host -ForegroundColor Red "The machine this script is running from cannot reach the VMware environment on port 902 to deploy the OVA, please resolve this issue and re-run the script."
Exit
  }

  Import-VApp -Source $HCXApplianceOVA -OvfConfiguration $ovfconfig -Name $HCXManagerVMName -VMHost $Cluster[0] -Datastore $datastore -DiskStorageFormat thin
  Write-Host -ForegroundColor Green "
Success: HCX Connector Deployed to On-Premises Cluster"

  
  #########################
  # Wait for PowerOn
  #########################
  

  # Power On the HCX Connector VM after deployment
  Write-Host -ForegroundColor Yellow "Powering on HCX Manager ..."
  Start-VM -VM $HCXManagerVMName -Confirm:$false
  
  # Waiting for HCX Connector to initialize
  while(1) {
      try {
          if($PSVersionTable.PSEdition -notlike "blahblahCore") {
              $requests = Invoke-WebRequest -Uri "https://$($HCXVMIP):9443" -Method GET -SkipCertificateCheck -TimeoutSec 5
          } else {
              $requests = Invoke-WebRequest -Uri "https://$($HCXVMIP):9443" -Method GET -TimeoutSec 5
          }
          if($requests.StatusCode -eq 200) {
              Write-Host -ForegroundColor Green "Success: HCX Manager is now ready to be configured!"
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
<#
If ($HCXOnPremRoleMapping -eq "vsphere.local") {
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
#>


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
  if ($hcxactivationkey -eq $null) {
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
    $command

  ######################
  # Create vMotion Network Profile
  ######################
  
  $vmotionnetworkbacking = Get-HCXNetworkBacking -Server $HCXVMIP -Name "$vmotionportgroup"
  
  $command = New-HCXNetworkProfile -PrimaryDNS $HCXVMDNS -DNSSuffix $HCXVMDomain -Name $vmotionnetworkprofilename -GatewayAddress $vmotionprofilegateway -IPPool $vmotionippool -Network $vmotionnetworkbacking -PrefixLength $vmotionnetworkmask
  $command | ConvertTo-Json
  
  
  ######################
  # Create Management Network Profile
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
  ###############
    
  $hcxDestinationSite = Get-HCXSite -Destination -ErrorAction Stop
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



  <#testing service mesh
  
while ("Succeeded" -ne $currentprovisioningstate)
{
$timeStamp = Get-Date -Format "hh:mm"
write-host -foregroundcolor yellow "$timestamp - Current Status: $currentprovisioningstate - Next Update In 10 Minutes"
Start-Sleep -Seconds 600
$provisioningstate = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $pcrg
$currentprovisioningstate = $provisioningstate.ProvisioningState
}


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
    #>

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

  #7/17/22