#########################################
# Get Tier-0 Routers
#########################################

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic $nsxtcredentialsencoded")
$headers.Add("Content-Type", "application/json")

$response = Invoke-RestMethod https://$nsxtip/api/v1/logical-routers?router_type=TIER0 -Method 'GET' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json