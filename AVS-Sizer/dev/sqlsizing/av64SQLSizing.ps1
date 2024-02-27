## Sets the host type to AV64
$global:sddcHostType = $importsizer[49].Value

if($testing -eq 1){
    .\sqlsizing\sqlvariables.ps1
    .\variablesinventory.ps1
}

### Calculate for AVAV64 All In
.\sqlsizing\sqlvariables.ps1


.\apipost.ps1
$global:responseAV64sql = Invoke-RestMethod $global:apiurlstaging -Method 'POST' -Headers $global:headers -Body $global:body 


### Calculate for AVAV64 All In Storage Only
.\sqlsizing\sqlvariables.ps1
$global:vCpuPerVM = 0
$global:vRamPerVM = 0

.\apipost.ps1
$global:responseAV64sqlStorageOnly = Invoke-RestMethod $apiurlstaging -Method 'POST' -Headers $headers -Body $body


### Calculate for AVAV64 All In CPU Only
.\sqlsizing\sqlvariables.ps1
$global:vRamPerVM = 0
$global:storagePerVM = 0

.\apipost.ps1
$global:responseAV64sqlCPUOnly = Invoke-RestMethod $apiurlstaging -Method 'POST' -Headers $headers -Body $body

### Calculate for AVAV64p All In Memory Only
.\sqlsizing\sqlvariables.ps1
$global:storagePerVM = 0
$global:vCpuPerVM = 0

.\apipost.ps1
$global:responseAV64sqlMemoryOnly = Invoke-RestMethod $apiurlstaging -Method 'POST' -Headers $headers -Body $body

if($global:testing -eq 1){
    Read-Host "press any key ... done"
}

## Read the Host Count and RAID Levels into a Variable
$global:hostcountAV64sql = $global:responseAV64sql.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV64sql = $global:responseAV64sql.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

## Write The Host Count and RAID Levels into the sizer.xlsm file

$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()
$ExcelSheet.Range("B14") = $global:hostcountAV64sql #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N14") = $global:fttraidAV64sql #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
