logintonsx

###################################
#Mgmt Link
###################################
$body = "{
    `n    `"subnets`": [
    `n        {
    `n            `"ip_addresses`": [
    `n                `"$global:mgmtnetworkgateway`"
    `n            ],
    `n            `"prefix_length`": 24
    `n        }
    `n    ],
    `n    `"linked_logical_switch_port_id`": {
    `n        `"target_id`": `"$global:mgmtswitchid`",
    `n        `"target_display_name`": `"Switch Port`",
    `n        `"target_type`": `"LogicalPort`",
    `n        `"is_valid`": true
    `n    },
    `n    `"urpf_mode`": `"STRICT`",
    `n    `"resource_type`": `"LogicalRouterDownLinkPort`",
    `n    `"id`": `"$global:mgmtdownlinkrouterportid`",
    `n    `"tags`": [
    `n        {
    `n            `"scope`": `"t1downlinkport`",
    `n            `"tag`": `"$NestedBuildName`"
    `n        }
    `n    ],
    `n    `"logical_router_id`": `"$NestedLabT1RouterID`",
    `n    `"_revision`": 0
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-router-ports/1b9d3c94-391c-4265-a461-a0d370dedcb8 -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json
