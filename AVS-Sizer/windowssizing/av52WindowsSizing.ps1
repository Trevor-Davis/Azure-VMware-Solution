## Sets the host type to AV52
$global:sddcHostType = $importsizer[37].Value

if($testing -eq 1){
    .\windowssizing\windowsvariables.ps1
    .\variablesinventory.ps1
}

### Calculate for AVAV52 All In
.\windowssizing\windowsvariables.ps1
.\apipost.ps1
$global:responseAV52windows = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 


if($global:testing -eq 1){
    Read-Host "press any key ... done"
}

## Read the Host Count and RAID Levels into a Variable
$global:hostcountAV52windows = $global:responseAV52windows.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV52windows = $global:responseAV52windows.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

## Write The Host Count and RAID Levels into the sizer.xlsm file

$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()
$ExcelSheet.Range("B8") = $global:hostcountAV52windows #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N8") = $global:fttraidAV52windows #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
