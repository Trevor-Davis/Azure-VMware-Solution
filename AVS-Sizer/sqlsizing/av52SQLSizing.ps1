## Sets the host type to AV52
$global:sddcHostType = $importsizer[37].Value

if($testing -eq 1){
    .\sqlsizing\sqlvariables.ps1
    .\variablesinventory.ps1
}

### Calculate for AVAV52 All In
.\sqlsizing\sqlvariables.ps1



.\apipost.ps1
$global:responseAV52sql = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 


### Calculate for AVAV52 All In Storage Only
.\sqlsizing\sqlvariables.ps1
$global:vCpuPerVM = 0
$global:vRamPerVM = 0



.\apipost.ps1
$global:responseAV52sqlStorageOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body


### Calculate for AVAV52 All In CPU Only
.\sqlsizing\sqlvariables.ps1
$global:vRamPerVM = 0
$global:storagePerVM = 0

.\apipost.ps1
$global:responseAV52sqlCPUOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

### Calculate for AVAV52p All In Memory Only
.\sqlsizing\sqlvariables.ps1
$global:storagePerVM = 0
$global:vCpuPerVM = 0

.\apipost.ps1
$global:responseAV52sqlMemoryOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

if($global:testing -eq 1){
    Read-Host "press any key ... done"
}

## Read the Host Count and RAID Levels into a Variable
$global:hostcountAV52sql = $global:responseAV52sql.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV52sql = $global:responseAV52sql.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

## Write The Host Count and RAID Levels into the sizer.xlsm file

$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()
$ExcelSheet.Range("B9") = $global:hostcountAV52sql #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N9") = $global:fttraidAV52sql #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
