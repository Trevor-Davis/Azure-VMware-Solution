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
   $OnPremVIServerUsername = "administrator@vsphere.local"
   $OnPremVIServerPassword = "0hDG3VqFyTd!"
   $PSCIP = $OnPremVIServerIP

#Get Cluster Name
write-host -ForegroundColor Red "You will be prompted to log into you on-premises vCenter Server $OnPremVIServerIP..."
Connect-VIServer -Server 192.168.0.2
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
Select the number of the portgroup which cooresponds to your MANAGEMENT network"
$managementportgroup = $items["$Selection"].Name

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


   
   $HCXCloudIP = "10.2.0.9"
   $HCXCloudPassword = "8xeR0e&b4-I9"
   $vmotionprofilegateway = "10.17.0.65"
   $vmotionnetworkmask = "27"
   $vmotionippool = "10.17.0.74-10.17.0.77"
   $mgmtprofilegateway = "10.17.0.1"
   $mgmtnetworkmask = "27"
   $mgmtippool = "10.17.0.10-10.17.0.16"
   $HCXOnPremRoleMapping = "vsphere.local"
   $hcxactivationkey = "431371541AB14BE795C7968AB2F409E0"





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