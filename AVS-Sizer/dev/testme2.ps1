<#
$Root = "C:\Users\tredavis\OneDrive - Microsoft\GitHub\Azure VMware Solution\AVS-Sizer\dev"
. $Root\apipost.ps1

$global:response36AllIn = Invoke-RestMethod 'https://stg.skyscraper.vmware.com/api/vmc-sizer/v5/recommendation' -Method 'POST' -Headers $headers -Body $body 

$response36AllIn


$hostcount36AllIn = $response36AllIn.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid36AllIn = $response36AllIn.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV36 Host Count All In: $hostcount36AllIn ($fttraid36AllIn)"



#>
$apiurl = "https://vmc.vmware.com/api/vmc-sizer/v5/recommendation?vmPlacement=false"


############################################################
$global:deduperatio = 1.25
$global:storagePerVM = 273
$global:computeOvercommitFactor = "5"
$global:vCpuPerCore = 5
$global:totalVMCount = 1162
$global:compressionRatio = 1.25
$global:fttFtmType = "FTT2_RAID6"
$global:vRamPerVM = 15.4
$global:sddcHostType = "AV36"
$global:memoryOvercommitFactor = "1.00"
$global:vCpuPerVM = 3.6




$global:headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$global:headers.Add("Content-Type", "application/json; charset=utf-8")
#$headers.Add("Authorization", "Basic dHJldm9yLnAuZGF2aXNATWljcm9zb2Z0LmNvbTpNaWNyb3NvZnQuMTIz")
$global:headers.Add("Accept","*/*")
#$headers.Add("Accept-Encoding","gzip, deflate, br")
$global:headers.Add("Connection","keep-alive")
$global:headers.Add("Transfer-Encoding","chunked")


$body = @"
{
    `"configurations`": {
        `"sddcHostType`": `"$sddcHostType`",
        `"ioSize`": `"4KB`",
        `"ioAccessPattern`": `"Random`",
        `"vSANArchitecture`": `"OSA`",
        `"totalVMCount`": $totalVMCount,
        `"cpuHeadroom`": 0.15,
        `"includeManagementVMs`": true,
        `"applianceSize`": `"AUTO`",
        `"vCpuPerVM`": $vCpuPerVM,
        `"memoryOvercommitFactor`": $memoryOvercommitFactor,
        `"totalIOPs`": 5000,
        `"iopsPerVM`": 50,
        `"separateCluster`": false,
        `"hyperThreadingFactor`": 1.25,
        `"cpuUtilization`": 0.3,
        `"computeOvercommitFactor`": $computeOvercommitFactor,
        `"clusterType`": `"SAZ`",
        `"ioRatio`": `"70/30`",
        `"storagePerVM`": $storagePerVM,
        `"fttFtmType`": `"$fttFtmType`",
        `"cloudEdition`": {
            `"id`": null,
            `"name`": null,
            `"type`": null,
            `"enabled`": false
        },
        `"vCpuPerCore`": $vCpuPerCore,
        `"memoryUtilization`": 1,
        `"compressionRatio`": $compressionRatio,
        `"vRamPerVM`": $vRamPerVM,
        `"storageThresholdFactor`": 0.8,
        `"cloudType`": `"AVS`",
        `"addonsList`": [
            {
                `"id`": `"HCX`",
                `"categoryID`": `"migration`",
                `"addonMetrics`": null,
                `"name`": `"VMware HCX`",
                `"isEnabled`": false,
                `"additionalData`": {
                    `"numberOfVMs`": null,
                    `"addonComponents`": [
                        {
                            `"id`": `"MONCapabilities`",
                            `"categoryID`": `"migration_capability`",
                            `"addonMetrics`": null,
                            `"name`": `"HCX Mobility Optimized Networking`",
                            `"isEnabled`": false,
                            `"additionalData`": {
                                `"numberOfVMs`": null,
                                `"addonComponents`": null
                            }
                        },
                        {
                            `"id`": `"HCXIX`",
                            `"categoryID`": `"migration_component`",
                            `"addonMetrics`": null,
                            `"name`": `"VMware HCX-IX Interconnect Appliance`",
                            `"isEnabled`": true,
                            `"additionalData`": {
                                `"numberOfVMs`": null,
                                `"addonComponents`": null
                            }
                        },
                        {
                            `"id`": `"HCXNE`",
                            `"categoryID`": `"migration_component`",
                            `"addonMetrics`": null,
                            `"name`": `"VMware HCX Network Extension Virtual Appliance`",
                            `"isEnabled`": true,
                            `"additionalData`": {
                                `"numberOfVMs`": null,
                                `"addonComponents`": null
                            }
                        },
                        {
                            `"id`": `"HCXWANOPT`",
                            `"categoryID`": `"migration_component`",
                            `"addonMetrics`": null,
                            `"name`": `"VMware HCX WAN Optimization Appliance`",
                            `"isEnabled`": false,
                            `"additionalData`": {
                                `"numberOfVMs`": null,
                                `"addonComponents`": null
                            }
                        },
                        {
                            `"id`": `"HCXSGW`",
                            `"categoryID`": `"migration_component`",
                            `"addonMetrics`": null,
                            `"name`": `"VMware HCX Sentinel Gateway Appliance`",
                            `"isEnabled`": true,
                            `"additionalData`": {
                                `"numberOfVMs`": null,
                                `"addonComponents`": null
                            }
                        },
                        {
                            `"id`": `"HCXSDR`",
                            `"categoryID`": `"migration_component`",
                            `"addonMetrics`": null,
                            `"name`": `"VMware HCX Sentinel Data Receiver Appliance`",
                            `"isEnabled`": true,
                            `"additionalData`": {
                                `"numberOfVMs`": null,
                                `"addonComponents`": null
                            }
                        }
                    ]
                }
            },
            {
                `"id`": `"VSR`",
                `"categoryID`": `"disaster_recovery`",
                `"addonMetrics`": null,
                `"name`": `"VMware Site Recovery`",
                `"isEnabled`": false,
                `"additionalData`": {
                    `"numberOfVMs`": 0,
                    `"addonComponents`": null
                }
            }
        ]
    },
    `"workloadProfiles`": [
        {
            `"profileName`": `"Workload Profile 1`",
            `"workloadType`": `"GPW_GVM`",
            `"isEnabled`": true,
            `"averageWorkloadData`": {
                `"totalVMCount`": $totalVMCount
            },
            `"sizingType`": `"ADVANCED_MANUAL`",
            `"separateCluster`": false,
            `"storagePreference`": `"vSAN_ONLY`",
            `"workloadProfileType`": `"GPW_GVM`",
            `"vmList`": [
                {
                    `"vmComputeInfo`": {
                        `"vCpu`": $vCpuPerVM,
                        `"vCpuPerCore`": $vCpuPerCore
                    },
                    `"vmMemoryInfo`": {
                        `"vRam`": $vRamPerVM
                    },
                    `"vmStorageInfo`": {
                        `"vmdkUsed`": $storagePerVM,
                        `"readIOPS`": 25,
                        `"writeIOPS`": 25
                    },
                    `"workloadProfileIndex`": 0
                }
            ],
            `"configurations`": {
                `"ioSize`": `"4KB`",
                `"ioAccessPattern`": `"Random`",
                `"vSANArchitecture`": `"OSA`",
                `"totalVMCount`": $totalVMCount,
                `"cpuHeadroom`": 0.15,
                `"includeManagementVMs`": true,
                `"applianceSize`": `"AUTO`",
                `"vCpuPerVM`": $vCpuPerVM,
                `"memoryOvercommitFactor`": $memoryOvercommitFactor,
                `"totalIOPs`": 5000,
                `"iopsPerVM`": 50,
                `"separateCluster`": false,
                `"hyperThreadingFactor`": 1.25,
                `"cpuUtilization`": 0.3,
                `"computeOvercommitFactor`": $computeOvercommitFactor,
                `"clusterType`": `"SAZ`",
                `"ioRatio`": `"70/30`",
                `"storagePerVM`": $storagePerVM,
                `"fttFtmType`": `"$fttFtmType`",
                `"cloudEdition`": {
                    `"id`": null,
                    `"name`": null,
                    `"type`": null,
                    `"enabled`": false
                },
                `"sddcHostType`": `"$sddcHostType`",
                `"vCpuPerCore`": $vCpuPerCore,
                `"memoryUtilization`": 1,
                `"compressionRatio`": $compressionRatio,
                `"vRamPerVM`": $vRamPerVM,
                `"storageThresholdFactor`": 0.8,
                `"cloudType`": `"AVS`"
            }
        }
    ]
}
"@

$response = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body


#$response = Invoke-RestMethod 'https://stg.skyscraper.vmware.com/api/vmc-sizer/v5/recommendation?vmPlacement=true' -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json


#$global:response36AllIn = Invoke-RestMethod 'https://stg.skyscraper.vmware.com/api/vmc-sizer/v5/recommendation' -Method 'POST' -Headers $headers -Body $body 

$global:response36AllIn = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

$response36AllIn


$hostcount36AllIn = $response36AllIn.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid36AllIn = $response36AllIn.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV36 Host Count All In: $hostcount36AllIn ($fttraid36AllIn)"


