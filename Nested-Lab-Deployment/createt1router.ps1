
logintonsx

$body = "{
`n    `"router_type`": `"TIER1`",
`n    `"resource_type`": `"LogicalRouter`",
`n                `"tags`": [
`n                {
`n                    `"scope`": `"T1Router`",
`n                    `"tag`": `"$NestedBuildName`"
`n                }
`n            ],
`n        `"high_availability_mode`": `"ACTIVE_STANDBY`",
`n    `"failover_mode`": `"NON_PREEMPTIVE`",
`n   `"display_name`": `"$NestedBuildName-T1Router`",
`n    `"_revision`": 0
`n}"

$response = Invoke-RestMethod https://$global:nsxtip/api/v1/logical-routers/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json | ConvertFrom-Json
$global:NestedLabT1RouterID = $response.id

Write-Host -ForegroundColor Yellow "Manually attach the T1 router just created to the T0 Router ... After completing, Press Any Key To Continue"
Read-Host