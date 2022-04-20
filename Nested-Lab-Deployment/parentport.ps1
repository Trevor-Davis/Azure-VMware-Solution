logintonsx

$logicalswitchid = "919bd4f6-9f64-4e3f-b66f-b556f9adb5dd" #the logical switch ID of the switch where the VM connects
$vifid = "23f1f869-dc85-4669-ad80-a1a72b7fde1e" #VIF ID of the VMs port.
$portid = "23af209f-6017-49bb-8d35-25dcda09ea45" #The ID of the VMs port which will convert to parent.
$parentvmname = "NestedLab-esxi-02-vmk1" #the name of the VM which port is being turned to parent.

$body = "{
    `n    `"logical_switch_id`": `"$logicalswitchid`",
    `n    `"attachment`": {
    `n        `"attachment_type`": `"VIF`",
    `n        `"id`": `"$vifid`",
    `n`"context`": {
    `n       `"vif_type`": `"PARENT`",
    `n       `"resource_type`": `"VifAttachmentContext`"
    `n     }
    `n    },
    `n    `"admin_state`": `"UP`",
    `n    `"address_bindings`": [],
    `n    `"ignore_address_bindings`": [],
    `n    `"internal_id`": `"$portid`",
    `n    `"resource_type`": `"LogicalPort`",
    `n    `"id`": `"$portid`",
    `n    `"display_name`": `"$parentvmname-PARENT`",
    `n    `"_revision`": 0
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-ports/$portid -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
    $response | ConvertTo-Json