## Sets the host type to AV36
$global:sddcHostType = $importsizer[35].Value

### Calculate for AV36 All In

.\apipost.ps1
$global:response36AllIn = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 
$global:response36AllIn

### Calculate for AV36 All In Storage Only
$global:vCpuPerVM = 0
$global:vRamPerVM = 0
.\apipost.ps1
$global:response36AllInStorageOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36AllInStorageOnly

### Calculate for AV36 All In CPU Only
$global:vRamPerVM = 0
$global:storagePerVM = 0
.\apipost.ps1
$global:response36AllInCPUOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36AllInCPUOnly

### Calculate for AV36 All In Memory Only
$global:storagePerVM = 0
$global:vCpuPerVM = 0
.\apipost.ps1
$global:response36AllInMemoryOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$global:response36AllInMemoryOnly
