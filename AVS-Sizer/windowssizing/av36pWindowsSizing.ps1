## Sets the host type to AV36p and the variables for the formulas
$global:sddcHostType = $importsizer[36].Value
$global:sizingfor = "Windows"
$global:hosttype = "AV36p"

$global:thehostcountinexcel_total = "b3"
$global:thefttraidinexcel_total = "n3"

$global:thehostcountinexcel_cpu = "w3"
$global:thefttraidinexcel_cpu = "x3"

$global:thehostcountinexcel_memory = "u3"
$global:thefttraidinexcel_memory = "v3"

$global:thehostcountinexcel_storage = "s3"
$global:thefttraidinexcel_storage = "t3"

$global:hostcoutforstorageonlyinexcel = "y3"

$global:excelsheetsizingresults = "sizingresults"

$global:directory = "$sizingfor" + "sizing"
$global:variablesfilename = "$sizingfor" + "variables.ps1"



$ExcelSheet = $ExcelWorkBook.Worksheets.Item($global:excelsheetsizingresults)
$ExcelSheet.activate()

### Calculate for AV36p Windows
. .\$global:directory\$global:variablesfilename

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 
$ExcelSheet.Range($global:thehostcountinexcel_total) = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thefttraidinexcel_total) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype



### Calculate for AV36p Windows Storage Only
. .\$global:directory\$global:variablesfilename
$global:vCpuPerVM = 0
$global:vRamPerVM = 0

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 

$global:hostsfor_storage = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thehostcountinexcel_storage) = $global:hostsfor_storage
$ExcelSheet.Range($global:thefttraidinexcel_storage) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


### Calculate for AV36p Windows CPU Only
. .\$global:directory\$global:variablesfilename
$global:vRamPerVM = 0
$global:storagePerVM = 0

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 

$global:hostsfor_cpu = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thehostcountinexcel_cpu) = $global:hostsfor_cpu
$ExcelSheet.Range($global:thefttraidinexcel_cpu) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


### Calculate for AV36p Windows Memory Only
. .\$global:directory\$global:variablesfilename
$global:storagePerVM = 0
$global:vCpuPerVM = 0

.\apipost.ps1
$global:api = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 

$global:hostsfor_memory = $global:api.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range($global:thehostcountinexcel_memory) = $global:hostsfor_memory
$ExcelSheet.Range($global:thefttraidinexcel_memory) = $global:api.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


