logintonsx

###################################
#Uplink Switch
###################################

$body = "{
    `n    `"switch_type`": `"DEFAULT`",
    `n    `"transport_zone_id`": `"$transportzone`",
    `n                `"tags`": [
    `n                {
    `n                    `"scope`": `"Switch`",
    `n                    `"tag`": `"$NestedBuildName`"
    `n                }
    `n            ],
    `n            `"admin_state`": `"UP`",
    `n    `"replication_mode`": `"MTEP`",
    `n    `"address_bindings`": [],
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
    `n    `"hybrid`": false,
    `n    `"span`": [],
    `n    `"resource_type`": `"LogicalSwitch`",
    `n    `"display_name`": `"$NestedBuildName-UplinkSwitch`",
    `n    `"_revision`": 0,
    `n    `"_schema`": `"/v1/schema/LogicalSwitch`"
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-switches/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json

    
    Write-Host -ForegroundColor Yellow "In the information above, you should see the ID field, copy the ID string (not including the quotes) and enter it here: " -NoNewline
    $global:uplinkswitchid = Read-Host
    

    ###################################
#Mgmt Switch
###################################

$body = "{
    `n    `"switch_type`": `"DEFAULT`",
    `n    `"transport_zone_id`": `"$transportzone`",
    `n                `"tags`": [
    `n                {
    `n                    `"scope`": `"Switch`",
    `n                    `"tag`": `"$NestedBuildName`"
    `n                }
    `n            ],
    `n            `"admin_state`": `"UP`",
    `n    `"replication_mode`": `"MTEP`",
    `n    `"address_bindings`": [],
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
    `n    `"hybrid`": false,
    `n    `"span`": [],
    `n    `"resource_type`": `"LogicalSwitch`",
    `n    `"display_name`": `"$NestedBuildName-MgmtSwitch`",
    `n    `"_revision`": 0,
    `n    `"_schema`": `"/v1/schema/LogicalSwitch`"
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-switches/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json

        
    Write-Host -ForegroundColor Yellow "In the information above, you should see the ID field, copy the ID string (not including the quotes) and enter it here: " -NoNewline
    $global:mgmtswitchid = Read-Host


    ###################################
#Workload Switch
###################################

$body = "{
    `n    `"switch_type`": `"DEFAULT`",
    `n    `"transport_zone_id`": `"$transportzone`",
    `n                `"tags`": [
    `n                {
    `n                    `"scope`": `"Switch`",
    `n                    `"tag`": `"$NestedBuildName`"
    `n                }
    `n            ],
    `n            `"admin_state`": `"UP`",
    `n    `"replication_mode`": `"MTEP`",
    `n    `"address_bindings`": [],
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
    `n    `"hybrid`": false,
    `n    `"span`": [],
    `n    `"resource_type`": `"LogicalSwitch`",
    `n    `"display_name`": `"$NestedBuildName-Workloads-VLAN-$vlanid`",
    `n    `"_revision`": 0,
    `n    `"_schema`": `"/v1/schema/LogicalSwitch`"
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-switches/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json

        
    Write-Host -ForegroundColor Yellow "In the information above, you should see the ID field, copy the ID string (not including the quotes) and enter it here: " -NoNewline
    $global:workloadswitchid = Read-Host