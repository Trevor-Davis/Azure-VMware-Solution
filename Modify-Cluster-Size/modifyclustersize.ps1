
# Written By: Trevor Davis
# Twitter: @vTrevorDavis
# Website: www.virtualworkloads.com

#######################################################################################
# Variables
#######################################################################################

$subid = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"         ## The subscription where the private cloud which you want to expand is deployed.
$ResourceGroupName = "VirtualWorkloads-AVS"             ## The resource group where the private cloud which you want to expand is deployed.
$NameOfPrivateCloud = "VirtualWorkloads-AVS-PC"         ## The private cloud name.
$ClusterSize = "3"                                      ## What should the cluster size be expanded to?  Maximum size is 16, and make sure you have enough quota.

#######################################################################################
# Check for Required Installs
#######################################################################################

if ($PSVersionTable.PSVersion.Major -lt 7){
    Write-Host -ForegroundColor Red "Please upgrade Powershell to 7.x"
    Exit-PSSession
  }
  
  $vmwarepowerclicheck = Find-Module -Name Az.VMware
  if ($vmwarepowerclicheck.Name -ne "Az.VMware") {
    Write-Host -ForegroundColor Red "Please install the Az.VMware Module"
    Exit-PSSession
    
  }
#######################################################################################
# Modify Private Cloud
#######################################################################################

Write-Host -ForegroundColor Red "You may need to manually move to your browswer or other pop-up in the background which has been launched"
Connect-AzAccount
Write-Host -ForegroundColor Blue "
Updating Private Cloud ...
"
$command = Update-AzVMwarePrivateCloud -Name $NameOfPrivateCloud -ResourceGroupName $ResourceGroupName -SubscriptionId $subid -ManagementClusterSize $ClusterSize
$command | ConvertTo-Json
