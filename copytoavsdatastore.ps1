$onpremvcenter = ""
$onpremvcenterusername = ""
$onpremvcenterpassword = ""
$avsvcenter = ""
$avsvcenterusername = ""
$avsvcenterpassword = ""
$filename = "" #this is the file you are copying.
$onpremdatacenter = "" #this is the name of the Datacenter in vCenter, on-prem.
$avsdatacenter = "" #this is the name of the DAtacenter in vCenter, within AVS.
$onpremdatastore = "" #name of the on-prem datastore where the file exists.
$avsdatastore = "" #name of the AVS datastore where tthe file will be copied.
$onpremdatastorefolder = "" #the folder where the source file exists, on-prem. 
$vsanpathid = ""
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


