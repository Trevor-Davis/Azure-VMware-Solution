logintonsx

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/logical-router-ports/$global:wandownlinkrouterportid -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/logical-router-ports/$global:mgmtdownlinkrouterportid -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/logical-routers/$global:NestedLabT1RouterID -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/logical-ports/$global:mgmtuplinkswitchportid -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/logical-ports/$global:wanuplinkswitchportid -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/logical-switches/$global:mgmtswitchid -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/logical-switches/$global:wanswitchid -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/logical-switches/$global:workloadswitchid -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/switching-profiles/$ipdiscoveryprofileid -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/switching-profiles/$macmanagementprofileid -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/switching-profiles/$securityprofileid -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

