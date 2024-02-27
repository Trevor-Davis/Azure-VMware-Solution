## Sets the host type to AV36
$global:sddcHostType = $importsizer[35].Value

### Calculate for AV36 Windows
. $locationofpowershell\WindowsVariables.ps1
. $locationofpowershell\apipost.ps1
$global:response36Windows = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 
$global:response36Windows

### Calculate for AV36 Windows Storage Only
. $locationofpowershell\WindowsVariables.ps1
$global:vCpuPerVM = 0
$global:vRamPerVM = 0
. $locationofpowershell\apipost.ps1
$global:response36WindowsStorageOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36WindowsStorageOnly

### Calculate for AV36 Windows CPU Only
. $locationofpowershell\WindowsVariables.ps1
$global:vRamPerVM = 0
$global:storagePerVM = 0
. $locationofpowershell\apipost.ps1
$global:response36WindowsCPUOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36WindowsCPUOnly

### Calculate for AV36 Windows Memory Only
. $locationofpowershell\WindowsVariables.ps1
$global:storagePerVM = 0
$global:vCpuPerVM = 0
. $locationofpowershell\apipost.ps1
$global:response36WindowsMemoryOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36WindowsMemoryOnly