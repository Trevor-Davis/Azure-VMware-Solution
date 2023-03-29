# Author: Trevor Davis
# Website: www.virtualworkloads.com
# Twitter: vTrevorDavis
# This script can be used to check HCX port communication to the AVS Private Cloud from an on-premises environment.
# INSTRUCTIONS: Modify the variables, then run the script. 

#variables

$global:sub = "1178f22f-6ce4-45e3-bd92-ba89930be5be" #the sub where the AVS private cloud is deployed, use the ID not the name.
$global:pcname = "VirtualWorkloads-AVS-PC01" #Name of the AVS private cloud
$global:pcrg = "VirtualWorkloads-AVS-PC01" #The resource group where AVS private cloud is deployed.



#DO NOT MODIFY BELOW THIS LINE #################################################
$ProgressPreference = 'SilentlyContinue'
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$HCXCloudUserID = "cloudadmin@vsphere.local"
$logfilename = "hcxportcheck.log"

#test-port function
$filename = "Function-test-port.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/scripts/main/Functions/$filename" -OutFile $env:TEMP\$filename
. $env:TEMP\$filename


#Azure Login
$filename = "Function-azurelogin.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$filename
. $env:TEMP\$filename

azurelogin -subtoconnect $sub

#Start Logging
Start-Transcript -Path $env:TEMP\$logfilename -Append

#Execution

Write-Host -foregroundcolor Yellow "
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
$vcenterpassword = $command.VcenterPassword
$HCXCloudPassword = ConvertFrom-SecureString -SecureString $vcenterpassword -AsPlainText

######################################
# Connect To Cloud HCX Manager
######################################
  $connecthcx = Connect-HCXServer -Server $HCXCloudIP -User $HCXCloudUserID -Password $HCXCloudPassword 
  If ($connecthcx.IsConnected -ne "True" ) {
    Write-Host -ForegroundColor yellow "Unable to Connect to HCX Manager in AVS ($($hcxcloudip)) on port 443"
    Exit
}

#this will list all HCX Appliances
$appliances =  Get-HCXInterconnectStatus -Server $HCXCloudIP 
$appliancecount = 0
$appliancelist=@{}
foreach ($appliance in $appliances)
{
 $appliancelist.add($appliance.ServiceComponent,$appliance.IpAddress -split ";")
 $appliancecount = $appliancecount+1
}
$appliancelist

$remove = $test.IpAddress.Replace("uplink:","")
$remove = $remove.Replace("management:","")
$remove = $remove.Replace("vmotion:","")
$remove = $remove.Replace(":","")
$theips = $remove -split ";"

Invoke-WebRequest -uri "https://connect.hcx.vmware.com" -ErrorVariable connecthcxerror
Clear-Host
Invoke-WebRequest -uri "https://hybridity-depot.vmware.com/" -ErrorVariable hybridityerror
Clear-Host

write-host -foregroundcolor yellow "Testing HCX Communication"
write-host -foregroundcolor yellow "========================="

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


if ($hybridityerror.ErrorRecord.ErrorDetails.Message.Contains("An error occurred while processing your request.") -eq "True")
{
Write-Host -foregroundcolor Yellow "Connection to hybridity-depot.vmware.com: " -NoNewline
Write-HOst -ForegroundColor Green "OK"
}
else {
  Write-Host -foregroundcolor Yellow "Connection to hybridity-depot.vmware.com: " -NoNewline
  Write-HOst -ForegroundColor Red "Failed"
  Write-Host "Most likely the network does not have access to the Internet"
}


foreach ($ip in $theips){


  $appliance = test-port -computer $ip -port 4500 -UDPtimeout 5000 -UDP


  if ($appliance.Open -eq "True")
{
Write-Host -foregroundcolor Yellow "Connection to '$appliance': " -NoNewline
Write-Host -ForegroundColor Green "OK"
}
else {
  Write-Host -foregroundcolor Yellow "Connection to '$appliance': " -NoNewline
  Write-Host -ForegroundColor Red "Failed"
  Write-Host -ForegroundColor Red "Most likely UDP Port 4500 is closed from this network to $appliance"
 }


}

