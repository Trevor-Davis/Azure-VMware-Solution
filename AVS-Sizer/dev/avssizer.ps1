$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json; charset=utf-8")
#$headers.Add("Authorization", "Basic dHJldm9yLnAuZGF2aXNATWljcm9zb2Z0LmNvbTpNaWNyb3NvZnQuMTIz")
$headers.Add("Accept","*/*")
#$headers.Add("Accept-Encoding","gzip, deflate, br")
$headers.Add("Connection","keep-alive")
$headers.Add("Transfer-Encoding","chunked")

$body = @"
{
    `"configurations`": {
        `"sddcHostType`": `"AV36P`",
        `"cpuHeadroom`": 0.0,
        `"includeManagementVMs`": true,
        `"vRamPerVM`": 52,
        `"clusterType`": `"SAZ`",
        `"storageThresholdFactor`": 0.8,
        `"fttFtmType`": `"AUTO_AUTO`",
        `"storagePerVM`": 2832,
        `"vCpuPerVM`": 6,
        `"ioAccessPattern`": `"Random`",
        `"cloudType`": `"AVS`",
        `"ioSize`": `"4KB`",
        `"vCpuPerCore`": 4,
        `"ioRatio`": `"70/30`",
        `"hyperThreadingFactor`": 1.25,
        `"compressionRatio`": 1.25,
        `"totalVMCount`": 382,
        `"separateCluster`": false,
        `"dedupRatio`": 1.5,
        `"totalIOPs`": 5000,
        `"iopsPerVM`": 50,
        `"applianceSize`": `"AUTO`",
        `"cpuUtilization`": 0.3,
        `"memoryOvercommitFactor`": 1,
        `"computeOvercommitFactor`": 5,
        `"memoryUtilization`": 1
    },
    `"workloadProfiles`": [
        {
            `"profileName`": `"Workload Profile 1`",
            `"workloadType`": `"GPW_GVM`",
            `"isEnabled`": true,
            `"averageWorkloadData`": {
                `"totalVMCount`": 382
            },
            `"sizingType`": `"ADVANCED_MANUAL`",
            `"separateCluster`": false,
            `"storagePreference`": `"vSAN_ONLY`",
            `"workloadProfileType`": `"GPW_GVM`",
            `"vmList`": [
                {
                    `"vmComputeInfo`": {
                        `"vCpu`": 4,
                        `"vCpuPerCore`": 4
                    },
                    `"vmMemoryInfo`": {
                        `"vRam`": 16
                    },
                    `"vmStorageInfo`": {
                        `"vmdkUsed`": 500,
                        `"readIOPS`": 25,
                        `"writeIOPS`": 25
                    },
                    `"workloadProfileIndex`": 0
                }
            ],
            `"configurations`": {
                `"cpuHeadroom`": 0.15,
                `"includeManagementVMs`": true,
                `"vRamPerVM`": 4,
                `"clusterType`": `"SAZ`",
                `"storageThresholdFactor`": 0.8,
                `"fttFtmType`": `"AUTO_AUTO`",
                `"storagePerVM`": 200,
                `"vCpuPerVM`": 2,
                `"ioAccessPattern`": `"Random`",
                `"sddcHostType`": `"AV36`",
                `"cloudType`": `"AVS`",
                `"ioSize`": `"4KB`",
                `"vCpuPerCore`": 4,
                `"ioRatio`": `"70/30`",
                `"hyperThreadingFactor`": 1.25,
                `"compressionRatio`": 1.25,
                `"totalVMCount`": 100,
                `"separateCluster`": false,
                `"dedupRatio`": 1.5,
                `"totalIOPs`": 5000,
                `"iopsPerVM`": 50,
                `"applianceSize`": `"AUTO`",
                `"cpuUtilization`": 0.3,
                `"memoryOvercommitFactor`": 1.25,
                `"computeOvercommitFactor`": 4,
                `"memoryUtilization`": 1,
                `"vSANArchitecture`": `"OSA`"
            }
        }
    ]
}
"@

$response = Invoke-RestMethod 'https://stg.skyscraper.vmware.com/api/vmc-sizer/v5/recommendation' -Method 'POST' -Headers $headers -Body $body 
$hosttype = $response.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$hosttype