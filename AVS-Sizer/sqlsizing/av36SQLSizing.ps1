## Sets the host type to AV36
$global:sddcHostType = $importsizer[35].Value

### Calculate for AV36 sql
. $locationofpowershell\sqlVariables.ps1
. $locationofpowershell\apipost.ps1
$global:response36sql = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 
$global:response36sql

### Calculate for AV36 sql Storage Only
. $locationofpowershell\sqlVariables.ps1
$global:vCpuPerVM = 0
$global:vRamPerVM = 0
. $locationofpowershell\apipost.ps1
$global:response36sqlStorageOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36sqlStorageOnly

### Calculate for AV36 sql CPU Only
. $locationofpowershell\sqlVariables.ps1
$global:vRamPerVM = 0
$global:storagePerVM = 0
. $locationofpowershell\apipost.ps1
$global:response36sqlCPUOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36sqlCPUOnly

### Calculate for AV36 sql Memory Only
. $locationofpowershell\sqlVariables.ps1
$global:storagePerVM = 0
$global:vCpuPerVM = 0
. $locationofpowershell\apipost.ps1
$global:response36sqlMemoryOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36sqlMemoryOnly