## Sets the host type to AV52
$global:sddcHostType = $importsizer[37].Value

if($testing -eq 1){
    .\allinsizing\allinvariables.ps1
    .\variablesinventory.ps1
}

### Calculate for AV52 All In
.\allinsizing\allinvariables.ps1
.\apipost.ps1
$global:responseAV52AllIn = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 

### Calculate for AV52 All In Storage Only
.\allinsizing\allinvariables.ps1
$global:vCpuPerVM = 0
$global:vRamPerVM = 0
.\apipost.ps1
$global:responseAV52AllInStorageOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body


### Calculate for AV52 All In CPU Only
.\allinsizing\allinvariables.ps1
$global:vRamPerVM = 0
$global:storagePerVM = 0
.\apipost.ps1
$global:responseAV52AllInCPUOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

### Calculate for AV52p All In Memory Only
.\allinsizing\allinvariables.ps1
$global:storagePerVM = 0
$global:vCpuPerVM = 0
.\apipost.ps1
$global:responseAV52AllInMemoryOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

if($global:testing -eq 1){
    Read-Host "press any key ... done"
}

## Read the Host Count and RAID Levels into a Variable
$global:hostcountAV52AllIn = $global:responseAV52AllIn.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV52AllIn = $global:responseAV52AllIn.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

$global:hostcountAV52AllInStorageOnly = $global:responseAV52AllInStorageOnly.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV52AllInStorageOnly = $global:responseAV52AllInStorageOnly.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

$global:hostcountAV52AllInCPUOnly = $global:responseAV52AllInCPUOnly.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV52AllInCPUOnly = $global:responseAV52AllInCPUOnly.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

$global:hostcountAV52AllInMemoryOnly = $global:responseAV52AllInMemoryOnly.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV52AllInMemoryOnly = $global:responseAV52AllInMemoryOnly.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

## Write The Host Count and RAID Levels into the sizer.xlsm file

$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()
$ExcelSheet.Range("B7") = $global:hostcountAV52AllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N7") = $global:fttraidAV52AllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("B21") = $global:hostcountAV52AllInCPUOnly #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("B22") = $global:hostcountAV52AllInMemoryOnly #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("B23") = $global:hostcountAV52AllInStorageOnly #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
