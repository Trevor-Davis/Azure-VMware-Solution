
$global:sub = "1178f22f-6ce4-45e3-bd92-ba89930be5be" #the sub where the AVS private cloud is deployed, use the ID not the name.
$global:pcname = "VirtualWorkloads-AVS-PC01" #Name of the AVS private cloud
$global:pcrg = "VirtualWorkloads-AVS-PC01" #The resource group where AVS private cloud is deployed.


#DO NOT MODIFY BELOW THIS LINE #################################################
. test-port-function.ps1


$ProgressPreference = 'SilentlyContinue'
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
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




#this will list all HCX Appliances
$appliances =  Get-HCXInterconnectStatus -Server $HCXCloudIP 
$hash=@{}
foreach ($appliance in $appliances)
{
 $hash.add($appliance.ServiceComponent,$appliance.IpAddress -split ";")
}
$hash

$Selection = 2

while ($selection -eq 2) {
  
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
Write-Host -ForegroundColor Red "PLEASE NOTE: " -NoNewline
Write-Host  "Please verify the IPs you entered are correct, inputing an incorrect IP could potentially result in a false positive connection."
Write-Host "1. Continue"
Write-Host "2. Re-Enter IP Addresses"
Write-Host "
Enter Your Selection: " -NoNewline
$Selection = Read-Host

}



#Run all the tests
Invoke-WebRequest -uri "https://connect.hcx.vmware.com" -ErrorVariable connecthcxerror
cls
Invoke-WebRequest -uri "https://hybridity-depot.vmware.com/" -ErrorVariable hybridityerror
cls
write-host -foregroundcolor yellow "Testing HCX Communication, Please Wait"
$nemgmtiptest = test-port -computer $nemgmtip -port 4500 -UDPtimeout 5000 -UDP
$neuplinkiptest = test-port -computer $neuplinkip -port 4500 -UDPtimeout 5000 -UDP
$ixmgmtiptest = test-port -computer $ixmgmtip -port 4500 -UDPtimeout 5000 -UDP
$ixuplinkiptest = test-port -computer $ixuplinkip -port 4500 -UDPtimeout 5000 -UDP
$ixvmotioniptest = test-port -computer $ixvmotionip -port 4500 -UDPtimeout 5000 -UDP

#write the results
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

if ($nemgmtiptest.Open -eq "True")
{
Write-Host -foregroundcolor Yellow "Connection to HCXServiceMesh-NE-R1 IP '$nemgmtip': " -NoNewline
Write-HOst -ForegroundColor Green "OK"
}
else {
  Write-Host -foregroundcolor Yellow "Connection to HCXServiceMesh-NE-R1 IP '$nemgmtip': " -NoNewline
  Write-HOst -ForegroundColor Red "Failed"
  Write-Host "Most likely UDP Port 4500 is closed from this network to $nemgmtip"
 }

 if ($neuplinkiptest.Open -eq "True")
{
Write-Host -foregroundcolor Yellow "Connection to HCXServiceMesh-NE-R1 IP '$neuplinkip': " -NoNewline
Write-HOst -ForegroundColor Green "OK"
}
else {
  Write-Host -foregroundcolor Yellow "Connection to HCXServiceMesh-NE-R1 IP '$neuplinkip': " -NoNewline
  Write-HOst -ForegroundColor Red "Failed"
  Write-Host "Most likely UDP Port 4500 is closed from this network to $neuplinkip"
 }

 if ($ixmgmtiptest.Open -eq "True")
{
Write-Host -foregroundcolor Yellow "Connection to HCXServiceMesh-IX-R1 '$ixmgmtip': " -NoNewline
Write-HOst -ForegroundColor Green "OK"
}
else {
  Write-Host -foregroundcolor Yellow "Connection to HCXServiceMesh-IX-R1 IP '$ixmgmtip': " -NoNewline
  Write-HOst -ForegroundColor Red "Failed"
  Write-Host "Most likely UDP Port 4500 is closed from this network to $ixmgmtip"
 }

 if ($ixuplinkiptest.Open -eq "True")
 {
 Write-Host -foregroundcolor Yellow "Connection to HCXServiceMesh-IX-R1 '$ixuplinkip': " -NoNewline
 Write-HOst -ForegroundColor Green "OK"
 }
 else {
   Write-Host -foregroundcolor Yellow "Connection to HCXServiceMesh-IX-R1 IP '$ixuplinkip': " -NoNewline
   Write-HOst -ForegroundColor Red "Failed"
   Write-Host "Most likely UDP Port 4500 is closed from this network to $ixuplinkip"
  }

  if ($ixvmotioniptest.Open -eq "True")
  {
  Write-Host -foregroundcolor Yellow "Connection to HCXServiceMesh-IX-R1 '$ixvmotionip': " -NoNewline
  Write-HOst -ForegroundColor Green "OK"
  }
  else {
    Write-Host -foregroundcolor Yellow "Connection to HCXServiceMesh-IX-R1 IP '$ixvmotionip': " -NoNewline
    Write-HOst -ForegroundColor Red "Failed"
    Write-Host "Most likely UDP Port 4500 is closed from this network to $ixvmotionip"
   }