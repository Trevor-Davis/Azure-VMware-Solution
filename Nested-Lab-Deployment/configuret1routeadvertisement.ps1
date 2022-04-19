logintonsx

$body = "{
    `n    `"enabled`": true,
    `n    `"advertise_nsx_connected_routes`": true,
    `n    `"advertise_nat_routes`": false,
    `n    `"advertise_static_routes`": true,
    `n    `"advertise_lb_vip`": false,
    `n    `"advertise_lb_snat_ip`": false,
    `n    `"advertise_dns_forwarder`": false,
    `n    `"advertise_ipsec_local_ip`": false,
    `n    `"logical_router_id`": `"$NestedLabT1RouterID`",
    `n    `"resource_type`": `"AdvertisementConfig`",
    `n    `"id`": `"$NestedLabT1RouterID`",
    `n    `"_revision`": 0
    `n}"
    
    $response = Invoke-RestMethod https://$nsxtip/api/v1/logical-routers/$NestedLabT1RouterID/routing/advertisement -Method 'PUT' -SkipCertificateCheck -Headers $headers -Body $body
    $response | ConvertTo-Json 
    