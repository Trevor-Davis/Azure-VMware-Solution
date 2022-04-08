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




clear
Invoke-Expression -Command $Folder\variables.ps1
Invoke-Expression -Command $Folder\createt1router.ps1
