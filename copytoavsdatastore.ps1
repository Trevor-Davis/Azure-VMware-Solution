$onpremvcenter = "10.34.0.10"
$onpremvcenterusername = "administrator@virtualworkloads.local"
$onpremvcenterpassword = "Microsoft.123!"
$avsvcenter = "192.168.0.2"
$avsvcenterusername = "cloudadmin@vsphere.local"
$avsvcenterpassword = "N-v9r2gR0%l8"
$filename = "test.iso" #this is the file you are copying.
$onpremdatacenter = "Nested-DC" #this is the name of the Datacenter in vCenter, on-prem.
$avsdatacenter = "SDDC-Datacenter" #this is the name of the DAtacenter in vCenter, within AVS.
$onpremdatastore = "nested-iscsi" #name of the on-prem datastore where the file exists.
$avsdatastore = "vsanDatastore" #name of the AVS datastore where tthe file will be copied.
$onpremdatastorefolder = "ISOs" #the folder where the source file exists, on-prem. 
$vsanpathid = "e673cd60-7432-69bf-62f0-1c34da50ce20"
#########################################################################################################

Connect-VIServer -Server $onpremvcenter -User $onpremvcenterusername -Password $onpremvcenterpassword
Connect-VIServer -Server $avsvcenter -User $avsvcenterusername -Password $avsvcenterpassword

mkdir $env:TEMP\datastorecopy -ErrorAction Ignore
Set-Location $env:TEMP\datastorecopy

Write-Host "Copying File $filename from $onpremvcenter"
Copy-DatastoreItem -Item vmstores:\$onpremvcenter@443\$onpremdatacenter\$onpremdatastore\$onpremdatastorefolder\$filename $env:TEMP\datastorecopy\  -Verbose

write-host "Copying file $filename to $avsvcenter"
Copy-DatastoreItem -Item $env:TEMP\datastorecopy\$filename -destination vmstores:\$avsvcenter@443\$avsdatacenter\$avsdatastore\$vsanpathid\ -Verbose

write-host "Cleaning Up"
Remove-Item $env:TEMP\datastorecopy\$filename


