## Sets the host type to AV52
$global:sddcHostType = $importsizer[37].Value

$global:sizingfor = "AllIn"
$global:hosttype = "AV52"

$global:thehostcountinexcel_total = "b7"
$global:thefttraidinexcel_total = "n7"

$global:thehostcountinexcel_cpu = "w7"
$global:thefttraidinexcel_cpu = "x7"

$global:thehostcountinexcel_memory = "u7"
$global:thefttraidinexcel_memory = "v7"

$global:thehostcountinexcel_storage = "s7"
$global:thefttraidinexcel_storage = "t7"

$global:hostcoutforstorageonlyinexcel = "y7"

$global:excelsheetsizingresults = "sizingresults"

$global:directory = "$sizingfor" + "sizing"
$global:variablesfilename = "$sizingfor" + "variables.ps1"



$ExcelSheet = $ExcelWorkBook.Worksheets.Item($global:excelsheetsizingresults)
$ExcelSheet.activate()

### Calculate for AV52 AllIn
. .\$global:directory\$global:variablesfilename

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 
$ExcelSheet.Range($global:thehostcountinexcel_total) = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thefttraidinexcel_total) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype



### Calculate for AV52 AllIn Storage Only
. .\$global:directory\$global:variablesfilename
$global:vCpuPerVM = 0
$global:vRamPerVM = 0

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 

$global:hostsfor_storage = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thehostcountinexcel_storage) = $global:hostsfor_storage
$ExcelSheet.Range($global:thefttraidinexcel_storage) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


### Calculate for AV52 AllIn CPU Only
. .\$global:directory\$global:variablesfilename
$global:vRamPerVM = 0
$global:storagePerVM = 0

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 

$global:hostsfor_cpu = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thehostcountinexcel_cpu) = $global:hostsfor_cpu
$ExcelSheet.Range($global:thefttraidinexcel_cpu) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


### Calculate for AV52 AllIn Memory Only
. .\$global:directory\$global:variablesfilename
$global:storagePerVM = 0
$global:vCpuPerVM = 0

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 

$global:hostsfor_memory = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thehostcountinexcel_memory) = $global:hostsfor_memory
$ExcelSheet.Range($global:thefttraidinexcel_memory) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


