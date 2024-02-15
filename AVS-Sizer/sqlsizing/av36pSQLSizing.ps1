## Sets the host type to AV36p
$global:sddcHostType = $importsizer[36].Value

if($testing -eq 1){
    .\sqlsizing\sqlvariables.ps1
    .\variablesinventory.ps1
}

### Calculate for AV36p All In
.\sqlsizing\sqlvariables.ps1
.\apipost.ps1
$global:response36psql = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 


### Calculate for AV36p All In Storage Only
.\sqlsizing\sqlvariables.ps1
$global:vCpuPerVM = 0
$global:vRamPerVM = 0
.\apipost.ps1
$global:response36psqlStorageOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body


### Calculate for AV36p All In CPU Only
.\sqlsizing\sqlvariables.ps1
$global:vRamPerVM = 0
$global:storagePerVM = 0

.\apipost.ps1
$global:response36psqlCPUOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

### Calculate for AV36pp All In Memory Only
.\sqlsizing\sqlvariables.ps1
$global:storagePerVM = 0
$global:vCpuPerVM = 0
.\apipost.ps1
$global:response36psqlMemoryOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

if($global:testing -eq 1){
    Read-Host "press any key ... done"
}

## Read the Host Count and RAID Levels into a Variable
$global:hostcount36psql = $global:response36psql.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraid36psql = $global:response36psql.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

## Write The Host Count and RAID Levels into the sizer.xlsm file

$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()
$ExcelSheet.Range("B4") = $global:hostcount36psql #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N4") = $global:fttraid36psql #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
