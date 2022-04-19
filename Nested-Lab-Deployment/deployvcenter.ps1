$vcenterdriveletter = 'f'
$pathtojsonfile = 'C:\Users\avs-admin\Documents\GitHub\Azure-VMware-Solution\Nested-Lab-Deployment'
Invoke-Expression "$($vcenterdriveletter):\vcsa-cli-installer\win32\vcsa-deploy.exe install --no-ssl-certificate-verification --accept-eula --acknowledge-ceip $($pathtojsonfile)\deployvcenter.json"
$command | ConvertTo-Json