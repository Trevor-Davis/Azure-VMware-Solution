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
https://192.168.0.3/api/v1/logical-switches/NestedLab2-Workloads-VLAN-74 -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/switching-profiles/$NestedBuildName-IPDiscovery -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/switching-profiles/$NestedBuildName-MACManagement -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

$response = Invoke-RestMethod `
https://$nsxtip/api/v1/switching-profiles/$NestedBuildName-SwitchSecurity -Method 'DELETE' -Headers $headers -SkipCertificateCheck
$response | ConvertTo-Json

