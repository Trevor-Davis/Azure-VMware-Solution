$Folder = "$env:TEMP\NestedLabDeploy"
if (Test-Path -Path $Folder) {
""
} else {
mkdir $env:TEMP\NestedLabDeploy
}



$filename = "variables.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/Nested-Lab-Deployment/$filename" `
-OutFile $Folder\$filename

$filename = "createt1router.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/Nested-Lab-Deployment/$filename" `
-OutFile $Folder\$filename

$filename = "createswitchingprofiles.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/Nested-Lab-Deployment/$filename" `
-OutFile $Folder\$filename

$filename = "createswitches.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/Nested-Lab-Deployment/$filename" `
-OutFile $Folder\$filename

$filename = "createresourcepool.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/Nested-Lab-Deployment/$filename" `
-OutFile $Folder\$filename

####################
#DELETE THIS
#####################
Copy-Item "C:\Users\avs-admin\Documents\GitHub\Azure-VMware-Solution\Nested-Lab-Deployment\*" -Destination "$Folder"



Invoke-Expression -Command $Folder\variables.ps1
#Invoke-Expression -Command $Folder\createt1router.ps1
#Invoke-Expression -Command $Folder\createswitchingprofiles.ps1
#Invoke-Expression -Command $Folder\createswitches.ps1
Invoke-Expression -Command $Folder\createresourcepool.ps1
