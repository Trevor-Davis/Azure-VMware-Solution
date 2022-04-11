logintonsx
#########################################
# Mgmt T1 Router Downlink Port
#########################################

$body = "{
    `n    `"subnets`": [
    `n        {
    `n            `"ip_addresses`": [
    `n                `"$mgmtnetworkgateway`"
    `n            ],
    `n            `"prefix_length`": 24
    `n        }
    `n    ],
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
   `n    `"urpf_mode`": `"STRICT`",
    `n    `"enable_multicast`": true,
    `n    `"resource_type`": `"LogicalRouterDownLinkPort`",
    `n                `"tags`": [
`n                {
`n                    `"scope`": `"t1downlinkport`",
`n                    `"tag`": `"$NestedBuildName`"
`n                }
`n            ],

    `n    `"display_name`": `"$NestedBuildName-MgmtDownlink`",
    `n    `"logical_router_id`": `"$NestedLabT1RouterID`",
    `n    `"_revision`": 0
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-router-ports/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json

    Write-Host -ForegroundColor Yellow "In the information above, you should see the ID field, copy the ID string (not including the quotes) and enter it here: " -NoNewline
    $global:mgmtdownlinkrouterportid = Read-Host

 
#########################################
# WAN T1 Router Downlink Port
#########################################   
    $body = "{
        `n    `"subnets`": [
        `n        {
        `n            `"ip_addresses`": [
        `n                `"$wannetworkgateway`"
        `n            ],
        `n            `"prefix_length`": 24
        `n        }
        `n    ],
        `n    `"urpf_mode`": `"STRICT`",
        `n    `"enable_multicast`": true,
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
        `n    `"resource_type`": `"LogicalRouterDownLinkPort`",
        `n                `"tags`": [
    `n                {
    `n                    `"scope`": `"t1downlinkport`",
    `n                    `"tag`": `"$NestedBuildName`"
    `n                }
    `n            ],
    
        `n    `"display_name`": `"$NestedBuildName-wanDownlink`",
        `n    `"logical_router_id`": `"$NestedLabT1RouterID`",
        `n    `"_revision`": 0
        `n}"
        
        $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-router-ports/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
        $response | ConvertTo-Json
    
        Write-Host -ForegroundColor Yellow "In the information above, you should see the ID field, copy the ID string (not including the quotes) and enter it here: " -NoNewline
        $global:wandownlinkrouterportid = Read-Host
        