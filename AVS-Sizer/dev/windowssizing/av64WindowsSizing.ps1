## Sets the host type to AV64
$global:sddcHostType = $importsizer[49].Value

if($testing -eq 1){
    .\windowssizing\windowsvariables.ps1
    .\variablesinventory.ps1
}

### Calculate for AVAV64 All In
.\windowssizing\windowsvariables.ps1


.\apipost.ps1
$global:responseAV64windows = Invoke-RestMethod $global:apiurlstaging -Method 'POST' -Headers $global:headers -Body $global:body 


if($global:testing -eq 1){
    Read-Host "press any key ... done"
}

## Read the Host Count and RAID Levels into a Variable
$global:hostcountAV64windows = $global:responseAV64windows.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV64windows = $global:responseAV64windows.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

## Write The Host Count and RAID Levels into the sizer.xlsm file

$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()
$ExcelSheet.Range("B13") = $global:hostcountAV64windows #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N13") = $global:fttraidAV64windows #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
