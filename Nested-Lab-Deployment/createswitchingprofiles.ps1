logintonsx

###################################
#IP Discovery Profile
###################################
$body = "{
`n    `"arp_snooping_enabled`": true,
`n    `"dhcp_snooping_enabled`": true,
`n    `"vm_tools_enabled`": true,
`n    `"arp_bindings_limit`": 100,
`n    `"dhcpv6_snooping_enabled`": false,
`n    `"nd_snooping_enabled`": false,
`n    `"nd_bindings_limit`": 3,
`n    `"vm_tools_v6_enabled`": false,
`n    `"duplicate_ip_detection`": {
`n        `"duplicate_ip_detection_enabled`": false
`n    },
`n    `"trust_on_first_use_enabled`": true,
`n    `"arp_nd_binding_timeout`": 10,
`n    `"resource_type`": `"IpDiscoverySwitchingProfile`",
`n                `"tags`": [
`n                {
`n                    `"scope`": `"SwitchingProfile`",
`n                    `"tag`": `"$NestedBuildName`"
`n                }
`n            ],
`n    `"display_name`": `"$NestedBuildName-IPDiscovery`",
`n    `"_revision`": 0
`n}"

$response = Invoke-RestMethod https://$nsxtip/api/v1/switching-profiles/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json | ConvertFrom-Json

$global:ipdiscoveryprofileid = $response.id

###################################
#Mac Manage Profile
###################################


$body = "{
    `n    `"mac_change_allowed`": true,
    `n    `"mac_learning`": {
    `n        `"unicast_flooding_allowed`": true,
    `n        `"aging_time`": 600,
    `n        `"enabled`": true,
    `n        `"limit`": 4096,
    `n        `"limit_policy`": `"ALLOW`",
    `n        `"remote_overlay_mac_limit`": 2048
    `n    },
    `n    `"resource_type`": `"MacManagementSwitchingProfile`",
    `n                `"tags`": [
        `n                {
        `n                    `"scope`": `"SwitchingProfile`",
        `n                    `"tag`": `"$NestedBuildName`"
        `n                }
        `n            ],
    `n    `"display_name`": `"$NestedBuildName-MACManagement`",
    `n    `"_revision`": 0
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/switching-profiles/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json | ConvertFrom-Json


    
    $global:macmanagementprofileid = $response.id
    
        
###################################
#security Profile
###################################

$body = "{
    `n    `"dhcp_filter`": {
    `n        `"server_block_enabled`": false,
    `n        `"client_block_enabled`": false,
    `n        `"v6_server_block_enabled`": false,
    `n        `"v6_client_block_enabled`": false
    `n    },
    `n    `"rate_limits`": {
    `n        `"rx_broadcast`": 0,
    `n        `"tx_broadcast`": 0,
    `n        `"rx_multicast`": 0,
    `n        `"tx_multicast`": 0,
    `n        `"enabled`": false
    `n    },
    `n    `"bpdu_filter`": {
    `n        `"enabled`": false,
    `n        `"white_list`": []
    `n    },
    `n    `"block_non_ip_traffic`": false,
    `n    `"ra_guard_enabled`": true,
    `n    `"resource_type`": `"SwitchSecuritySwitchingProfile`",
    `n                `"tags`": [
    `n                {
    `n                    `"scope`": `"SwitchingProfile`",
    `n                    `"tag`": `"$NestedBuildName`"
    `n                }
    `n            ],
    `n    `"display_name`": `"$NestedBuildName-SwitchSecurity`",
    `n    `"_revision`": 0
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/switching-profiles/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json | ConvertFrom-Json
 
    $global:securityprofileid = $response.id
