logintonsx

$logicalswitchid = "af1d59ae-4059-46c1-9274-018ff2543b9f" ##randomize this to create the switch, when attached other VMs to this switch make sure to use the switch ID of the child switch created
$childvmname = "NestedLab-esxi-02-vmk1" #name of the VM, then just add CHILD to it
$id = "00f7734a-8d82-4281-69ab-3abf0b625ab1" #random
$parentvifid = "23f1f869-dc85-4669-ad80-a1a72b7fde1e" #the vif ID of the parent port of this VM.
$vlandid = "74"
$appid = "19993705-a60c-4af0-9bbb-2e4014200044" #randomize

$body = "{
    `n  `"logical_switch_id`": `"$logicalswitchid`",
    `n  `"display_name`": `"$childvmname-CHILD`", 
    `n  `"description`": `"`",
    `n  `"admin_state`": `"UP`",
    `n  `"address_bindings`": [
    `n    {
    `n      `"mac_address`": `"00:00:00:00:00:00`",
    `n      `"ip_address`": `"127.0.0.1`"
    `n    }
    `n  ],
    `n  `"attachment`": {
    `n    `"id`": `"$id`", 
    `n    `"context`": {
    `n      `"allocate_addresses`": `"None`",
    `n      `"parent_vif_id`": `"$parentvifid`", 
    `n      `"traffic_tag`": `"$vlandid`",
    `n      `"resource_type`": `"VifAttachmentContext`",
    `n      `"vif_type`": `"CHILD`",
    `n      `"app_id`": `"$appid`" 
    `n    },
    `n    `"attachment_type`": `"VIF`"
    `n  }
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-ports/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json