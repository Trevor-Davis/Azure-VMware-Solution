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
    `n        `"target_id`": `"$global:mgmtuplinkswitchportid`",
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
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-router-ports/$global:mgmtdownlinkrouterportid -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json


###################################
#WAN Link
###################################
$body = "{
    `n    `"subnets`": [
    `n        {
    `n            `"ip_addresses`": [
    `n                `"$global:wannetworkgateway`"
    `n            ],
    `n            `"prefix_length`": 24
    `n        }
    `n    ],
    `n    `"linked_logical_switch_port_id`": {
    `n        `"target_id`": `"$global:wanuplinkswitchportid`",
    `n        `"target_display_name`": `"Switch Port`",
    `n        `"target_type`": `"LogicalPort`",
    `n        `"is_valid`": true
    `n    },
    `n    `"urpf_mode`": `"STRICT`",
    `n    `"resource_type`": `"LogicalRouterDownLinkPort`",
    `n    `"id`": `"$global:wandownlinkrouterportid`",
    `n    `"tags`": [
    `n        {
    `n            `"scope`": `"t1downlinkport`",
    `n            `"tag`": `"$NestedBuildName`"
    `n        }
    `n    ],
    `n    `"logical_router_id`": `"$NestedLabT1RouterID`",
    `n    `"_revision`": 0
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-router-ports/$global:wandownlinkrouterportid -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json
