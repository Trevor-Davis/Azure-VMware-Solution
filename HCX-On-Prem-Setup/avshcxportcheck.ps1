# Author: Trevor Davis
# Website: www.virtualworkloads.com
# Twitter: vTrevorDavis
# This script can be used to deploy HCX to an on-prem location and fully connect and configure for use w/ an AVS Private Cloud
# For guidance on this script please refer to https://www.virtualworkloads.com 
 

#variables

#AVS Private Cloud Information
$sub = "1178f22f-6ce4-45e3-bd92-ba89930be5be" #the sub where the AVS private cloud is deployed, use the ID not the name.
$pcname = "VirtualWorkloads-AVS-PC01" #Name of the AVS private cloud
$pcrg = "VirtualWorkloads-AVS-PC01" #The resource group where AVS private cloud is deployed.

<#
#On Premises Info
$OnPremVIServerIP ="192.168.89.10" #This is the IP of the vCenter Server on-premises where HCX needs to be deployed.
$OnPremVIServerUsername = "administrator@vsphere.local" #It's recommended to use administrator@vsphere.local
$OnPremVIServerPassword = "Microsoft1!"
$OnPremCluster = "Cluster-VirtualWorkloads" #The name of teh cluster where HCX Appliance will be deployed.
$datastore = "iscsi" #the name of the datastore on-prem to deploy HCX Manager
$VMNetwork = "PortGroup-VLAN14" #What network should HCX Manager be deployed ... must be the name of the portgroup in vCenter.

#Inputs for the deployment of HCX Manager on-premises
$HCXOnPremAdminPassword = "Microsoft1!" #When HCX is installed on-prem there will be a local user created called admin, provide the password you would like assigned to that user.
$HCXVMIP = "192.168.14.9" #The IP to assign to HCX Manager.
$HCXVMNetmask ="24" #netmask for the $vmnetwork
$HCXVMGateway = "192.168.14.1" #gateway for the $vmnetwork
$HCXVMDNS ="10.20.0.4" #DNS Server to use
$HCXVMDomain = "virtualworkloads.local" #domain to assign to HCX Manager
#$AVSVMNTP = "10.20.0.4" #NTP Server for HCX Manager
$PSCIP = $OnPremVIServerIP #typically the platform services controller is the on-prem vcenter, if not change to the IP of the psc. 
$ssodomain = "vsphere.local" #This would be the SSO domain of the on-prem vCenter Server, recommended for initial setup would be to use the vsphere.local domain
$ssogroup = "Administrators" #This would be the SSO domain group which holds the HCX Admins, for initial setup recommendation is to keep this setting.
$HCXOnPremLocation = "Buffalo" #The closest major city where the HCX Manager is deployed on-prem.

#HCX Network Profile Inputs
$managementportgroup = "PortGroup-VLAN14" #The on-premises management network portgroup name.
$mgmtprofilegateway = "192.168.14.1" #The gateway of the network for the $managementportgroup
$mgmtippool = "192.168.14.200-192.168.14.204" #two continguous IP addresses from the $managementportgroup network
$mgmtnetworkmask = "24" #The netmask of the $managementportgroup network.

#L2 Extension Info
$l2extendedVDS = "DSwitch" #What is the name of the VDS which has portgroups that need to be L2 extended to Azure VMware Solution. 

#>

#DO NOT MODIFY BELOW THIS LINE #################################################


$ProgressPreference = 'SilentlyContinue'
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
<#
$HCXManagerVMName = "HCX-Manager"
$HCXOnPremAdminUserID = "admin"
$mgmtnetworkprofilename = "HCXNetworkProfile"
$hcxComputeProfileName = "HCXComputeProfile"
$hcxServiceMeshName = "HCXServiceMesh"
#>
$HCXCloudUserID = "cloudadmin@vsphere.local"
$logfilename = "hcxportcheck.log"

#Azure Login
$filename = "Function-azurelogin.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$filename

azurelogin -subtoconnect $sub

#Start Logging
Start-Transcript -Path $env:TEMP\$logfilename -Append

#Execution

Write-Host -foregroundcolor Magenta "
Checking HCX Port Communication to $pcname"


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



######################################
# Connect To Cloud HCX Manager
######################################
  $connecthcx = Connect-HCXServer -Server $HCXCloudIP -User $HCXCloudUserID -Password $HCXCloudPassword 
  while ($connecthcx.IsConnected -ne "True" ) {
    Write-Host -ForegroundColor yellow 'Waiting for On-Premises HCX Connector Services To Re-Start ... Checking Again In 1 Minute ....'
    Start-Sleep -Seconds 60
    $connecthcx = Connect-HCXServer -Server $HCXVMIP -User $OnPremVIServerUsername -Password $OnPremVIServerPassword 
  
  }




$appliances =  Get-HCXInterconnectStatus -Server $HCXCloudIP 
 
$hash=@{}

foreach ($appliance in $appliances)

{

 $hash.add($appliance.ServiceComponent,$appliance.IpAddress -split ";")

}
$hash

Write-Host -ForegroundColor Yellow "
Please Provide the Values From The Table Above
----------------------------------------------
"

Write-Host "HCXServiceMesh-NE-R1" -NoNewline
write-host -foregroundcolor yellow " - Management IP Address: " -NoNewline
$nemgmtip = Read-Host 
Write-Host "HCXServiceMesh-NE-R1" -NoNewline
write-host -foregroundcolor yellow " - Uplink IP Address: " -NoNewline
$neuplinkip = Read-Host 
Write-Host "
HCXServiceMesh-IX-R1" -NoNewline
write-host -foregroundcolor yellow " - Management IP Address: " -NoNewline
$ixmgmtip = Read-Host 
Write-Host "HCXServiceMesh-IX-R1" -NoNewline
write-host -foregroundcolor yellow " - Uplink IP Address: " -NoNewline
$ixuplinkip = Read-Host 
Write-Host "HCXServiceMesh-IX-R1" -NoNewline
write-host -foregroundcolor yellow " - vMotion IP Address: " -NoNewline
$ixvmotionip = Read-Host 
write-host ""

Invoke-WebRequest -uri "https://connect.hcx.vmware.com" -ErrorVariable connecthcxerror
cls
Invoke-WebRequest -uri "https://hybridity-depot.vmware.com/" -ErrorVariable hybridityerror
cls

if ($connecthcxerror.ErrorRecord.ErrorDetails.Message.Contains("403") -eq "True")
{
Write-Host -foregroundcolor Yellow "Connection to connect.hcx.vmware.com: " -NoNewline
Write-HOst -ForegroundColor Green "OK"
}
else {
  Write-Host -foregroundcolor Yellow "Connection to connect.hcx.vmware.com: " -NoNewline
  Write-HOst -ForegroundColor Red "Failed"
  Write-Host "Most likely the network does not have access to the Internet"
}


if ($hybridityerror.ErrorRecord.ErrorDetails.Message.Contains("An error occurred while processing your request") -eq "True")
{
Write-Host -foregroundcolor Yellow "Connection to hybridity-depot.vmware.com: " -NoNewline
Write-HOst -ForegroundColor Green "OK"
}
else {
  Write-Host -foregroundcolor Yellow "Connection to connect.hcx.vmware.com: " -NoNewline
  Write-HOst -ForegroundColor Red "Failed"
  Write-Host "Most likely the network does not have access to the Internet"
}

$udpobject = new-Object system.Net.Sockets.Udpclient(11001)
$udpobject.client.receivetimeout = 1000
$a = new-object system.text.asciiencoding
$byte = $a.GetBytes("$(Get-Date)")
$udpobject.Connect("127.0.0.1",11001)
[void]$udpobject.Send($byte,$byte.length)
$remoteendpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any,0)
$receivebytes = $udpobject.Receive([ref]$remoteendpoint)
 
#Convert returned data into string format
[string]$returndata = $a.GetString($receivebytes)
 
#Uses the IPEndPoint object to show that the host responded.
Write-Host "This is the message you received: $($returndata.ToString())"
Write-Host "This message was sent from: $($remoteendpoint.address.ToString()) on their port number: $($remoteendpoint.Port.ToString())"


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
HCX Manager Still Getting Ready ... Will Check Again In 1 Minute ..."
        Start-Sleep 60
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
  
  ################################
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
Write-Host -ForegroundColor Green "Complete"
}

$status = Get-HCXServiceMesh -Name $hcxServiceMeshName -Server $hcxvmip
$status.ServiceStatus

#>