## Sets the host type to AV36p
$global:sddcHostType = $importsizer[36].Value

### Calculate for AVAV36p All In
.\windowssizing\windowsvariables.ps1
.\apipost.ps1
$global:responseAV36pwindows = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 


if($global:testing -eq 1){
    Read-Host "press any key ... done"
}

## Read the Host Count and RAID Levels into a Variable
$global:hostcountAV36pwindows = $global:responseAV36pwindows.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV36pwindows = $global:responseAV36pwindows.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

## Write The Host Count and RAID Levels into the sizer.xlsm file

$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()
$ExcelSheet.Range("B3") = $global:hostcountAV36pwindows #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N3") = $global:fttraidAV36pwindows #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
