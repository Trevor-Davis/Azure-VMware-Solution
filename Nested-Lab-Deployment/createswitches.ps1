Write-Host -ForegroundColor Yellow "You are going to now have to input the IDs of the varying security profiles which were just created, please log into the NSX-T Manager Console, navigate you way to the Switch Security Profiles .... PRESS ANY KEY TO CONTINUE"
Read-Host

Write-Host -ForegroundColor Yellow "What is the ID of the Switch Profile $NestedBuildName-SwitchSecurity: " -NoNewline
$securityprofileid = Read-Host

Write-Host -ForegroundColor Yellow "What is the ID of the Switch Profile $NestedBuildName-MACManagement: " -NoNewline
$macmanagementprofileid = Read-Host

Write-Host -ForegroundColor Yellow "What is the ID of the Switch Profile $NestedBuildName-IPDiscovery: " -NoNewline
$ipdiscoveryprofileid = Read-Host

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