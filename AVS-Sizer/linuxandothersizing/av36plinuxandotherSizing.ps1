## Sets the host type to AV36p
$global:sddcHostType = $importsizer[36].Value

if($testing -eq 1){
    .\linuxandothersizing\linuxandothervariables.ps1
    .\variablesinventory.ps1
}

### Calculate for AV36p All In
.\linuxandothersizing\linuxandothervariables.ps1

.\apipost.ps1
$global:response36plinuxandother = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 


### Calculate for AV36p All In Storage Only
.\linuxandothersizing\linuxandothervariables.ps1
$global:vCpuPerVM = 0
$global:vRamPerVM = 0

.\apipost.ps1
$global:response36plinuxandotherStorageOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body


### Calculate for AV36p All In CPU Only
.\linuxandothersizing\linuxandothervariables.ps1
$global:vRamPerVM = 0
$global:storagePerVM = 0



.\apipost.ps1
$global:response36plinuxandotherCPUOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

### Calculate for AV36pp All In Memory Only
.\linuxandothersizing\linuxandothervariables.ps1
$global:storagePerVM = 0
$global:vCpuPerVM = 0
.\apipost.ps1
$global:response36plinuxandotherMemoryOnly = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body

if($global:testing -eq 1){
    Read-Host "press any key ... done"
}

## Read the Host Count and RAID Levels into a Variable
$global:hostcount36plinuxandother = $global:response36plinuxandother.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraid36plinuxandother = $global:response36plinuxandother.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

## Write The Host Count and RAID Levels into the sizer.xlsm file

$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()
$ExcelSheet.Range("B5") = $global:hostcount36plinuxandother #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N5") = $global:fttraid36plinuxandother #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
