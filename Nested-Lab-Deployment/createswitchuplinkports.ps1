logintonsx
#########################################
# Mgmt Uplink Port
#########################################

$body = "{
    `n    `"logical_switch_id`": `"$mgmtswitchid`",
    `n    `"admin_state`": `"UP`",
    `n    `"address_bindings`": [],
    `n    `"ignore_address_bindings`": [],
    `n    `"switching_profile_ids`": [
        `n        {
        `n            `"key`": `"SwitchSecuritySwitchingProfile`",
        `n            `"value`": `"$securityprofileid`"
        `n        },
        `n        {
        `n            `"key`": `"IpDiscoverySwitchingProfile`",
        `n            `"value`": `"$ipdiscoveryprofileid`"
        `n        },
        `n        {
        `n            `"key`": `"MacManagementSwitchingProfile`",
        `n            `"value`": `"$macmanagementprofileid`"
        `n        }
        `n    ],    
    `n    `"resource_type`": `"LogicalPort`",
    `n                `"tags`": [
`n                {
`n                    `"scope`": `"UplinkPort`",
`n                    `"tag`": `"$NestedBuildName`"
`n                }
`n            ],
    `n    `"display_name`": `"T1-Uplink-Port`",
    `n    `"_revision`": 0
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-ports/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json

    Write-Host -ForegroundColor Yellow "In the information above, you should see the ID field, copy the ID string (not including the quotes) and enter it here: " -NoNewline
    $global:mgmtuplinkswitchportid = Read-Host

 
#########################################
# WAN Switch Downlink Port
#########################################   

$body = "{
    `n    `"logical_switch_id`": `"$wanswitchid`",
    `n    `"admin_state`": `"UP`",
    `n    `"address_bindings`": [],
    `n    `"ignore_address_bindings`": [],
    `n    `"switching_profile_ids`": [
        `n        {
        `n            `"key`": `"SwitchSecuritySwitchingProfile`",
        `n            `"value`": `"$securityprofileid`"
        `n        },
        `n        {
        `n            `"key`": `"IpDiscoverySwitchingProfile`",
        `n            `"value`": `"$ipdiscoveryprofileid`"
        `n        },
        `n        {
        `n            `"key`": `"MacManagementSwitchingProfile`",
        `n            `"value`": `"$macmanagementprofileid`"
        `n        }
        `n    ],    
    `n    `"resource_type`": `"LogicalPort`",
    `n                `"tags`": [
`n                {
`n                    `"scope`": `"UplinkPort`",
`n                    `"tag`": `"$NestedBuildName`"
`n                }
`n            ],
    `n    `"display_name`": `"T1-Uplink-Port`",
    `n    `"_revision`": 0
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-ports/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json

    Write-Host -ForegroundColor Yellow "In the information above, you should see the ID field, copy the ID string (not including the quotes) and enter it here: " -NoNewline
    $global:wanuplinkswitchportid = Read-Host
