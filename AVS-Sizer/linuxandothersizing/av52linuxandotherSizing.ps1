## Sets the host type to AV52
$global:sddcHostType = $importsizer[37].Value

if($testing -eq 1){
    .\linuxandothersizing\linuxandothervariables.ps1
    .\variablesinventory.ps1
}

### Calculate for AVAV52 All In
.\linuxandothersizing\linuxandothervariables.ps1



.\apipost.ps1
$global:responseAV52linuxandother = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 


### Calculate for AVAV52 All In Storage Only
.\linuxandothersizing\linuxandothervariables.ps1
$global:vCpuPerVM = 0
$global:vRamPerVM = 0



.\apipost.ps1
$global:responseAV52linuxandotherStorageOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body


### Calculate for AVAV52 All In CPU Only
.\linuxandothersizing\linuxandothervariables.ps1
$global:vRamPerVM = 0
$global:storagePerVM = 0




.\apipost.ps1
$global:responseAV52linuxandotherCPUOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

### Calculate for AVAV52p All In Memory Only
.\linuxandothersizing\linuxandothervariables.ps1
$global:storagePerVM = 0
$global:vCpuPerVM = 0



.\apipost.ps1
$global:responseAV52linuxandotherMemoryOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

if($global:testing -eq 1){
    Read-Host "press any key ... done"
}

## Read the Host Count and RAID Levels into a Variable
$global:hostcountAV52linuxandother = $global:responseAV52linuxandother.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV52linuxandother = $global:responseAV52linuxandother.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

## Write The Host Count and RAID Levels into the sizer.xlsm file

$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()
$ExcelSheet.Range("B10") = $global:hostcountAV52linuxandother #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N10") = $global:fttraidAV52linuxandother #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
