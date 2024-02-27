## Sets the host type to AV36p
$global:sddcHostType = $importsizer[36].Value

if($testing -eq 1){
    .\allinsizing\allinvariables.ps1
    .\variablesinventory.ps1
}


### Calculate for AV36p All In
.\allinsizing\allinvariables.ps1

.\apipost.ps1
$global:response36pAllIn = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 


### Calculate for AV36p All In Storage Only
.\allinsizing\allinvariables.ps1
$global:vCpuPerVM = 0
$global:vRamPerVM = 0

.\apipost.ps1
$global:response36pAllInStorageOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body


### Calculate for AV36p All In CPU Only
.\allinsizing\allinvariables.ps1
$global:vRamPerVM = 0
$global:storagePerVM = 0

.\apipost.ps1
$global:response36pAllInCPUOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

### Calculate for AV36pp All In Memory Only
.\allinsizing\allinvariables.ps1
$global:storagePerVM = 0
$global:vCpuPerVM = 0



.\apipost.ps1
$global:response36pAllInMemoryOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

if($global:testing -eq 1){
    Read-Host "press any key ... done"
}

## Read the Host Count and RAID Levels into a Variable
$global:hostcount36pAllIn = $global:response36pAllIn.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraid36pAllIn = $global:response36pAllIn.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

$global:hostcount36pAllInStorageOnly = $global:response36pAllInStorageOnly.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraid36pAllInStorageOnly = $global:response36pAllInStorageOnly.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

$global:hostcount36pAllInCPUOnly = $global:response36pAllInCPUOnly.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraid36pAllInCPUOnly = $global:response36pAllInCPUOnly.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

$global:hostcount36pAllInMemoryOnly = $global:response36pAllInMemoryOnly.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraid36pAllInMemoryOnly = $global:response36pAllInMemoryOnly.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

## Write The Host Count and RAID Levels into the sizer.xlsm file

$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()
$ExcelSheet.Range("B2") = $global:hostcount36pAllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N2") = $global:fttraid36pAllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("B17") = $global:hostcount36pAllInCPUOnly #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("B18") = $global:hostcount36pAllInMemoryOnly #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("B19") = $global:hostcount36pAllInStorageOnly #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
