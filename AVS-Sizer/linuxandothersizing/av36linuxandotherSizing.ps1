## Sets the host type to AV36
$global:sddcHostType = $importsizer[35].Value

### Calculate for AV36 linuxandother
. $locationofpowershell\linuxandotherVariables.ps1
. $locationofpowershell\apipost.ps1
$global:response36linuxandother = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 
$global:response36linuxandother

### Calculate for AV36 linuxandother Storage Only
. $locationofpowershell\linuxandotherVariables.ps1
$global:vCpuPerVM = 0
$global:vRamPerVM = 0
. $locationofpowershell\apipost.ps1
$global:response36linuxandotherStorageOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36linuxandotherStorageOnly

### Calculate for AV36 linuxandother CPU Only
. $locationofpowershell\linuxandotherVariables.ps1
$global:vRamPerVM = 0
$global:storagePerVM = 0
. $locationofpowershell\apipost.ps1
$global:response36linuxandotherCPUOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36linuxandotherCPUOnly

### Calculate for AV36 linuxandother Memory Only
. $locationofpowershell\linuxandotherVariables.ps1
$global:storagePerVM = 0
$global:vCpuPerVM = 0
. $locationofpowershell\apipost.ps1
$global:response36linuxandotherMemoryOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36linuxandotherMemoryOnly