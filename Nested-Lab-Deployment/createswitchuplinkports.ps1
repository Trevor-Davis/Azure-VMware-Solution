logintonsx
#########################################
# Mgmt Uplink Port
#########################################
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic YWRtaW46IXE5ZHk0NiExc0lD")
$headers.Add("Content-Type", "application/json")
$headers.Add("Cookie", "JSESSIONID=A538F3BEE348992507E8B807BE56B94A")

$body = "{
`n    `"logical_switch_id`": `"$mgmtswitchid`",
`n    `"admin_state`": `"UP`",
`n    `"address_bindings`": [],
`n    `"ignore_address_bindings`": [],
`n    `"resource_type`": `"LogicalPort`",
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
`n    `"display_name`": `"T1-Uplink`",
`n    `"description`": `"`"
`n}"

$response = Invoke-RestMethod https://$nsxtip/api/v1/logical-ports/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json | ConvertFrom-Json 

$global:mgmtuplinkswitchportid = $response.id
     
#########################################
# WAN Switch Uplionik Port
#########################################   
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic YWRtaW46IXE5ZHk0NiExc0lD")
$headers.Add("Content-Type", "application/json")
$headers.Add("Cookie", "JSESSIONID=A538F3BEE348992507E8B807BE56B94A")

$body = "{
`n    `"logical_switch_id`": `"$wanswitchid`",
`n    `"admin_state`": `"UP`",
`n    `"address_bindings`": [],
`n    `"ignore_address_bindings`": [],
`n    `"resource_type`": `"LogicalPort`",
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
`n    `"display_name`": `"T1-Uplink`",
`n    `"description`": `"`"
`n}"

$response = Invoke-RestMethod https://$nsxtip/api/v1/logical-ports/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck 
$response | ConvertTo-Json | ConvertFrom-Json 
$global:wanuplinkswitchportid = $response.id
