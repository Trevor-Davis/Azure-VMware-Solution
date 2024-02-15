## Sets the host type to AV64
$global:sddcHostType = $importsizer[49].Value

if($testing -eq 1){
    .\allinsizing\allinvariables.ps1
    .\variablesinventory.ps1
}

### Calculate for AV64 All In
.\allinsizing\allinvariables.ps1

.\apipost.ps1
$global:responseAV64AllIn = Invoke-RestMethod $global:apiurlstaging -Method 'POST' -Headers $global:headers -Body $global:body 


### Calculate for AV64 All In Storage Only
.\allinsizing\allinvariables.ps1
$global:vCpuPerVM = 0
$global:vRamPerVM = 0

.\apipost.ps1
$global:responseAV64AllInStorageOnly = Invoke-RestMethod $apiurlstaging -Method 'POST' -Headers $headers -Body $body


### Calculate for AV64 All In CPU Only
.\allinsizing\allinvariables.ps1
$global:vRamPerVM = 0
$global:storagePerVM = 0



.\apipost.ps1
$global:responseAV64AllInCPUOnly = Invoke-RestMethod $apiurlstaging -Method 'POST' -Headers $headers -Body $body

### Calculate for AV64p All In Memory Only
.\allinsizing\allinvariables.ps1
$global:storagePerVM = 0
$global:vCpuPerVM = 0

.\apipost.ps1
$global:responseAV64AllInMemoryOnly = Invoke-RestMethod $apiurlstaging -Method 'POST' -Headers $headers -Body $body

if($global:testing -eq 1){
    Read-Host "press any key ... done"
}

## Read the Host Count and RAID Levels into a Variable
$global:hostcountAV64AllIn = $global:responseAV64AllIn.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV64AllIn = $global:responseAV64AllIn.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

$global:hostcountAV64AllInStorageOnly = $global:responseAV64AllInStorageOnly.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV64AllInStorageOnly = $global:responseAV64AllInStorageOnly.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

$global:hostcountAV64AllInCPUOnly = $global:responseAV64AllInCPUOnly.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV64AllInCPUOnly = $global:responseAV64AllInCPUOnly.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

$global:hostcountAV64AllInMemoryOnly = $global:responseAV64AllInMemoryOnly.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV64AllInMemoryOnly = $global:responseAV64AllInMemoryOnly.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

## Write The Host Count and RAID Levels into the sizer.xlsm file

$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()
$ExcelSheet.Range("B12") = $global:hostcountAV64AllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N12") = $global:fttraidAV64AllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("B25") = $global:hostcountAV64AllInCPUOnly #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("B26") = $global:hostcountAV64AllInMemoryOnly #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("B27") = $global:hostcountAV64AllInStorageOnly #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
