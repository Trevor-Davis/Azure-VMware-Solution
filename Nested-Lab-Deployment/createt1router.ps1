#########################################
# Get Tier-0 Routers
#########################################

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
$response | ConvertTo-Json

Write-Host -ForegroundColor Red "Now Connect the T1 Router Just Created to the Tier-0 Router Manually ... Press Any Key When This Has Been Completed"
Read-Host 