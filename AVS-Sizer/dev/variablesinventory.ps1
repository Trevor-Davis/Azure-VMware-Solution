write-host "testing:" $global:testing
write-host "apiurl:" $global:apiurl
write-host "apiurlstaging:" $global:apiurlstaging
write-host "filename: "$global:filename
write-host "buttonclicked:" $global:buttonclicked
Write-Host "Global Variables" -ForegroundColor Red
write-host "CompressionRatio = $global:compressionRatio"
Write-Host "vCPUPerCore = $global:vcpupercore"
Write-Host "Compute OverCommit: = $global:computeOvercommitFactor"
write-host "rvtoolslocation: "$rvtoolslocation
write-host "rvtoolsfilename: "$rvtoolsfilename 
write-host "memoryOverCommitFactor: $global:memoryOvercommitFactor"
Write-Host "All In Models" -ForegroundColor Red
write-host "Total VMs: $global:totalVMCount"
write-host "vCPUPerVM: $global:vCpuPerVM"
write-host "StoragePerVM: $global:storagePerVM" 
write-host "vRamPerVM: $global:vRamPerVM"
Write-Host "Variables for the API" -ForegroundColor Red
Write-Host "sddcHostType: $sddcHostType"
Write-Host "totalVMCount" $totalVMCount
Write-Host "vCpuPerVM" $vCpuPerVM
Write-Host "memoryOvercommitFactor" $memoryOvercommitFactor
Write-Host "computeOvercommitFactor" $computeOvercommitFactor
Write-Host "storagePerVM" $storagePerVM
Write-Host "fttFtmType" $fttFtmType
Write-Host "vCpuPerCore" $vCpuPerCore
Write-Host "compressionRatio" $compressionRatio
Write-Host "vRamPerVM" $vRamPerVM
