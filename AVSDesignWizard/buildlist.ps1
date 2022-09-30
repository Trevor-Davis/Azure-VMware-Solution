Param(
  [Parameter(Mandatory=$true)]
  [string]$Name,
  [string]$AVSPrivateCloudDeployed,
  [string]$HowDoesOnPremConnecttoAzure,
  [string]$GlobalReachAvailable,
  [string]$exrtovnetorvwan,
  [string]$internetegresspoint,
  [string]$internetegressfirewall,
  [string]$internetfacingservices,
  [string]$vmtovminavsfirewall,
  [string]$vmtofromonpremfirewall,
  [string]$avstofromazurefirewall,
  [string]$hcxneeded,
  [string]$srmneeded,
  [string]$adforvcenterneeded,
  [string]$dhcpforavsworkloadsneeded
)


$variable = @(
    $AVSPrivateCloudDeployed,
    $AVSPrivateCloudDeployed,
    $HowDoesOnPremConnecttoAzure, #these need to be added twice because there are two options which are not yes or no which, for those which are yes or no only one result could require a URL, in this case, either option requires a URL.
    $GlobalReachAvailable,
    $exrtovnetorvwan,
    $exrtovnetorvwan,
    $internetegresspoint,
    $internetegresspoint,
    $internetegressfirewall,
    $internetegressfirewall,
    $internetegressfirewall,
    $internetegressfirewall,
    $internetfacingservices,

    $vmtovminavsfirewall,
    $vmtovminavsfirewall,
    
    $vmtofromonpremfirewall,
    $vmtofromonpremfirewall,
    $vmtofromonpremfirewall,
    $vmtofromonpremfirewall,
    $vmtofromonpremfirewall,

    $avstofromazurefirewall,
    $avstofromazurefirewall,
    $avstofromazurefirewall,
    $avstofromazurefirewall,    
    
    $hcxneeded,
    $srmneeded,
    $adforvcenterneeded,
    $adforvcenterneeded,
    $dhcpforavsworkloadsneeded
    )

$test = @(
    "No",#$AVSPrivateCloudDeployed,
    "No",#$AVSPrivateCloudDeployed,
    "Site-to-Site VPN",#$HowDoesOnPremConnecttoAzure,
    "Yes",#$GlobalReachAvailable,
    "Virtual WAN",#$exrtovnetorvwan,
    "Virtual Network",#$exrtovnetorvwan,
    "On-Premises",#$internetegresspoint,
    "Azure",#$internetegresspoint,
    "NSX-T in AVS",#$internetegressfirewall,
    "3rd party Network Virtual Appliance in AVS",#$internetegressfirewall,
    "3rd party Network Virtual Appliance in Azure vNet",#$internetegressfirewall,
    "Azure Firewall",#$internetegressfirewall,
    "Yes",#$internetfacingservices,

    "NSX-T in AVS",#$vmtovminavsfirewall,
    "3rd party Network Virtual Appliance in AVS",#$vmtovminavsfirewall,
    
    "NSX-T in AVS",#$vmtofromonpremfirewall,
    "3rd party Network Virtual Appliance in AVS",#$vmtofromonpremfirewall,
    "3rd party Network Virtual Appliance in Azure vNet",#$vmtofromonpremfirewall,
    "Azure Firewall",#$vmtofromonpremfirewall,
    "On-Premises Firewall",#$vmtofromonpremfirewall,
    
    "NSX-T in AVS",#$avstofromazurefirewall,
    "3rd party Network Virtual Appliance in AVS",#$avstofromazurefirewall,
    "3rd party Network Virtual Appliance in Azure vNet",#$avstofromazurefirewall,
    "Azure Firewall",#$avstofromazurefirewall,

    "Yes",#$hcxneeded,
    "Yes",#$srmneeded,
    "Yes",#$adforvcenterneeded,
    "Yes",#$adforvcenterneeded,
    "Yes" #$dhcpforavsworkloadsneeded
)

$link = @(
"Deploy Private Cloud; https://www.virtualworkloads.com/2022/06/azure-vmware-solution-ingredients-deploy-private-cloud/", #"No",#$AVSPrivateCloudDeployed,
"Connect Private Cloud to Azure Virtual Network Gateway; https://www.virtualworkloads.com/2022/06/azure-vmware-solution-ingredients-connect-avs-private-cloud-to-azure-virtual-network/", #"No",#$AVSPrivateCloudDeployed,
"Connect to On-Premises With a Site-to-Site VPN; https://www.virtualworkloads.com/2022/07/azure-vmware-solution-connect-avs-and-site-to-site-vpn-connected-on-premises-location/", #"Site-to-Site VPN",#$HowDoesOnPremConnecttoAzure,
"Connect to On-Premises Using Global Reach; https://www.virtualworkloads.com/2022/07/azure-vmware-solution-ingredients-connect-on-premises-and-azure-vmware-solution-via-expressroute-globalreach/", #"Yes",#$GlobalReachAvailable,
"xx", #"Virtual WAN",#$exrtovnetorvwan,
"xx", #"Virtual Network",#$exrtovnetorvwan,
"xx", #"On-Premises",#$internetegresspoint,
"xx", #"Azure",#$internetegresspoint,
"xx", #"NSX-T in AVS",#$internetegressfirewall,
"Inspect Internet Egress Traffic Using NVA in AVS; https://techcommunity.microsoft.com/t5/azure-migration-and/firewall-integration-in-azure-vmware-solution/ba-p/2254961", #"3rd party Network Virtual Appliance in AVS",#$avstofromazurefirewall,
"Inspect Internet Egress Traffic Using Azure NVA; https://www.virtualworkloads.com/2022/06/azure-vmware-solution-ingredients-inspect-internet-egress-with-network-virtual-appliance-in-azure-virtual-network/", #"3rd party Network Virtual Appliance in Azure vNet",#$internetegressfirewall,
"xx", #"Azure Firewall",#$internetegressfirewall,
"xx", #"Yes",#$internetfacingservices,

"xx", #"NSX-T in AVS",#$vmtovminavsfirewall,
"NVA in AVS to Inspect VM to VM Communication within AVS; https://techcommunity.microsoft.com/t5/azure-migration-and/firewall-integration-in-azure-vmware-solution/ba-p/2254961", #"3rd party Network Virtual Appliance in AVS",#$vmtovminavsfirewall,

"xx", #"NSX-T in AVS",#$vmtofromonpremfirewall,
"Inspect AVS to/from On-Premises Using NVA in AVS; https://techcommunity.microsoft.com/t5/azure-migration-and/firewall-integration-in-azure-vmware-solution/ba-p/2254961", #"3rd party Network Virtual Appliance in AVS",#$vmtofromonpremfirewall,
"xx", #"3rd party Network Virtual Appliance in Azure vNet",#$vmtofromonpremfirewall,
"xx", #"Azure Firewall",#$vmtofromonpremfirewall,
"Inspect AVS Traffic to/from On-Premises Using On-Premises Firewall; https://www.virtualworkloads.com/2022/06/azure-vmware-solution-ingredients-secure-communications-between-avs-and-on-premises-using-on-premises-firewall/	", #"On-Premises Firewall",#$vmtofromonpremfirewall,


"xx", #"NSX-T in AVS",#$avstofromazurefirewall,
"Inspect AVS to/from Azure VMs and Services Using NVA in AVS; https://techcommunity.microsoft.com/t5/azure-migration-and/firewall-integration-in-azure-vmware-solution/ba-p/2254961", #"3rd party Network Virtual Appliance in AVS",#$avstofromazurefirewall,
"xx", #"3rd party Network Virtual Appliance in Azure vNet",#$avstofromazurefirewall,
"xx", #"Azure Firewall",#$avstofromazurefirewall,

"xx", #"Yes",#$hcxneeded,
"Deploy SRM to Azure VMware Solution Private Cloud; https://docs.microsoft.com/en-us/azure/azure-vmware/disaster-recovery-using-vmware-site-recovery-manager", #"Yes",#$srmneeded,
"Configure DNS Forwarding; https://docs.microsoft.com/en-us/azure/azure-vmware/configure-dns-azure-vmware-solution",
"Configure External Identity Source for vCenter; https://docs.microsoft.com/en-us/azure/azure-vmware/configure-identity-source-vcenter", #"Yes",#$adforvcenterneeded,
"xx"  #"Yes" #$dhcpforavsworkloadsneeded
)
$arraycounter = 0
$steps = @()
$number = 0

$v = 0
$t = 0
$l = 0

while ($arraycounter -lt $variable.Length) {
    If ($variable[$v] -eq $test[$t])
    {$number = $number + 1
        $url = $link[$l]
    $steps += "$number. $url"
    }
    $v = $v+1
    $t = $t+1
    $l = $l+1    
    $arraycounter = $arraycounter + 1

    
}

$steps

$variable.Length
$steps.Length
$test.Length

