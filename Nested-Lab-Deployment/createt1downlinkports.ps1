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
    $response | ConvertTo-Json | ConvertFrom-Json
    $global:mgmtdownlinkrouterportid = $response.id

 
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
        $response | ConvertTo-Json | ConvertFrom-Json
    
    
        $global:wandownlinkrouterportid = $response.id
        