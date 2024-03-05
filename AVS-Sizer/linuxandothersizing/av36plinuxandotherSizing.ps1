## Sets the host type to AV36p and the variables for the formulas
$global:sddcHostType = $importsizer[36].Value
$global:sizingfor = "LinuxAndOther"
$global:hosttype = "AV36p"

$global:thehostcountinexcel_total = "b5"
$global:thefttraidinexcel_total = "n5"

$global:thehostcountinexcel_cpu = "w5"
$global:thefttraidinexcel_cpu = "x5"

$global:thehostcountinexcel_memory = "u5"
$global:thefttraidinexcel_memory = "v5"

$global:thehostcountinexcel_storage = "s5"
$global:thefttraidinexcel_storage = "t5"

$global:hostcoutforstorageonlyinexcel = "y5"

$global:excelsheetsizingresults = "sizingresults"

$global:directory = "$sizingfor" + "sizing"
$global:variablesfilename = "$sizingfor" + "variables.ps1"

$ExcelSheet = $ExcelWorkBook.Worksheets.Item($global:excelsheetsizingresults)
$ExcelSheet.activate()

### Calculate for AV36p LinuxAndOther
. .\$global:directory\$global:variablesfilename

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 
$ExcelSheet.Range($global:thehostcountinexcel_total) = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thefttraidinexcel_total) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype



### Calculate for AV36p LinuxAndOther Storage Only
. .\$global:directory\$global:variablesfilename
$global:vCpuPerVM = 0
$global:vRamPerVM = 0

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 

$global:hostsfor_storage = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thehostcountinexcel_storage) = $global:hostsfor_storage
$ExcelSheet.Range($global:thefttraidinexcel_storage) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


### Calculate for AV36p LinuxAndOther CPU Only
. .\$global:directory\$global:variablesfilename
$global:vRamPerVM = 0
$global:storagePerVM = 0

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 

$global:hostsfor_cpu = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thehostcountinexcel_cpu) = $global:hostsfor_cpu
$ExcelSheet.Range($global:thefttraidinexcel_cpu) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


### Calculate for AV36p LinuxAndOther Memory Only
. .\$global:directory\$global:variablesfilename
$global:storagePerVM = 0
$global:vCpuPerVM = 0

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 

$global:hostsfor_memory = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thehostcountinexcel_memory) = $global:hostsfor_memory
$ExcelSheet.Range($global:thefttraidinexcel_memory) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


