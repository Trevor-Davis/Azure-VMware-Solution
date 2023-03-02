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
$PSCIP = $OnPremVIServerIP #typically the platform services controller is the on-prem vcenter, if not change to the IP of the psc. 
$ssodomain = "vsphere.local" #This would be the SSO domain of the on-prem vCenter Server, recommended for initial setup would be to use the vsphere.local domain
$ssogroup = "Administrators" #This would be the SSO domain group which holds the HCX Admins, for initial setup recommendation is to keep this setting.
$HCXOnPremLocation = "Buffalo" #The closest major city where the HCX Manager is deployed on-prem.

<#
$vmotionportgroup = "NestedLab" #Either the vMotion network portgroup name, or the management network port group name.
$vmotionprofilegateway = "192.168.89.1" #The gateway of the network for the $vmotionportgroup
$vmotionippool = "192.168.89.200-192.168.89.202" #two continguous IP addresses from the $vmotionportgroup network
$vmotionnetworkmask = "24" #The netmask of the $vmotionportgroup network.
#>
$managementportgroup = "NestedLab" #The management network portgroup name.
$mgmtprofilegateway = "192.168.89.1" #The gateway of the network for the $managementportgroup
$mgmtippool = "192.168.89.200-192.168.89.204" #two continguous IP addresses from the $managementportgroup network
$mgmtnetworkmask = "24" #The netmask of the $managementportgroup network.

$l2extendedVDS = "DSwitch"

#DO NOT MODIFY BELOW THIS LINE #################################################
$ProgressPreference = 'SilentlyContinue'
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$hcxovafilename = "VMware-HCX-Connector-4.5.0.0-20616025.ova"

$HCXManagerVMName = "HCX-Manager-for-$pcname"
$HCXOnPremUserID = "administrator@vsphere.local"
$HCXCloudUserID = "cloudadmin@vsphere.local"
# $vmotionnetworkprofilename = "vMotionNetworkProfile"
$mgmtnetworkprofilename = "HCXNetworkProfile"
$hcxComputeProfileName = "HCXComputeProfile"
$hcxServiceMeshName = "HCXServiceMesh"


#Azure Login
$filename = "Function-azurelogin.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$filename

azurelogin -subtoconnect $sub

#Start Logging
Start-Transcript -Path $env:TEMP\"hcxonpreminstall.log" -Append

#Execution

Write-Host "
Deploying HCX Manager to vCenter $OnPremVIServerIP and Connecting to $pcname"



#######################################################################################
# Connect to On-Prem vCenter
#######################################################################################  

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

<#
write-host -ForegroundColor Yellow "What is the USERNAME and PASSWORD for the ON-PREMISES vCenter Server ($OnPremVIServerIP) where the VMware HCX Connector will be deployed?"
write-host -ForegroundColor White -nonewline "Username: "
$OnPremVIServerUsername = Read-Host 
write-host -ForegroundColor White -nonewline "Password: "
$OnPremVIServerPassword = Read-Host -MaskInput
#>




#######################################################################################
# Install HCX To Private Cloud
#######################################################################################

$test = Get-AzVMwareAddon -PrivateCloudName $pcname -ResourceGroupName $pcrg -AddonType hcx -ErrorAction Ignore

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
write-host -ForegroundColor Yellow -nonewline "Enter a HCX Activation Key"
write-host -foregroundcolor Yellow -nonewline "

You can create a HCX Activation Key in the Azure Portal.  
Select your PRIVATE CLOUD > MANAGE > ADD-ONs > MIGRATION USING HCX

If you would like to enter an activation key at a later time just press Enter

Activation Key: "

$Selection = Read-Host
$hcxactivationkey = $Selection

#######################################################################################
#Deploy HCX OVA On-Prem
#######################################################################################
  


#define the OVA
#Assumption is the OVA is in teh same directory as this powershell script

$mypath = $MyInvocation.MyCommand.Path 
$mypath = split-path $mypath -Parent
Set-Location -Path $mypath
$mypath
Read-Host

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
  $ovfconfig.Common.mgr_cli_passwd.Value = $HCXOnPremPassword
  $ovfconfig.Common.mgr_root_passwd.Value = $HCXOnPremPassword
  $ovfconfig.Common.mgr_isSSHEnabled.Value = $true
  $ovfconfig.Common.mgr_cli_passwd.Value = $HCXOnPremPassword
  $ovfconfig.Common.mgr_root_passwd.Value = $HCXOnPremPassword 