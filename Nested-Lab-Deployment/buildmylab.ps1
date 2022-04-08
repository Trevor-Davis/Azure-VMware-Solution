$Folder = "$env:TEMP\NestedLabDeploy"
if (Test-Path -Path $Folder) {
""
} else {
mkdir $env:TEMP\NestedLabDeploy
}

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/Nested-Lab-Deployment/variables.ps1" -OutFile $env:TEMP\AVSDeploy\avsdeploy.ps1
$ProgressPreference = 'Continue'


Invoke-Expression -Command $env:TEMP\NestedLabDeploy\variables.ps1
