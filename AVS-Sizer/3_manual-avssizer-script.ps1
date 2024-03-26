<#
.\globalvariables.ps1  


$global:totalVMCount = 1000
$global:vCpuPerVM = 5000/$global:totalVMCount
$global:vCpuTotal = 5000
$global:storagePerVM = 50000/$global:totalVMCount
$global:storagePerVMTotal = 50000
$global:vRamPerVM = 100000/$global:totalVMCount
$global:vRamPerVMTotal = 100000
#>



$global:manualsizing = 1
########################################################################################
# Opens the sizer.xlsm file and begins to write data to it.
########################################################################################

.\opensizerfile.ps1

$global:ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()

$ExcelSheet.Range("B2:b33") = ""
$ExcelSheet.Range("N2:N15") = ""
$ExcelSheet.Range("s2:s15") = ""
$ExcelSheet.Range("t2:t15") = ""
$ExcelSheet.Range("u2:u15") = ""
$ExcelSheet.Range("v2:v15") = ""
$ExcelSheet.Range("w2:w15") = ""
$ExcelSheet.Range("x2:x15") = ""

$ExcelSheet.Range("a1") = "Manual"
$ExcelSheet.Range("b30") = $totalvminput.Text
$ExcelSheet.Range("b31") = $totalvcpuinput.Text
$ExcelSheet.Range("b32") = $totalstorageinput.Text
$ExcelSheet.Range("b33") = $totalmemoryinput.Text
$app = $ExcelObj.Application 
$app.Run("cleartheimportedsheets") # Run the Excel Macro in the Sizer file to import the RV Tools file.


############################################################################################################
#The following now queries the APIs to get the multiple calculations
############################################################################################################


$global:memoryOvercommitFactor = 1
$global:vCpuPerVMBackup = $global:vCpuPerVM
$global:vRamPerVMBackup = $global:vRamPerVM
$global:storagePerVMBackup = $global:storagePerVM

<#"vCPU Per VM"  | Out-File -FilePath c:\temp\variables.txt -Append
$global:vCpuPerVM | Out-File -FilePath c:\temp\variables.txt -Append
"vRAM Per VM"  | Out-File -FilePath c:\temp\variables.txt -Append
$global:vRamPerVM | Out-File -FilePath c:\temp\variables.txt -Append
"Storage Per VM"  | Out-File -FilePath c:\temp\variables.txt -Append
$global:storagePerVM | Out-File -FilePath c:\temp\variables.txt -Append
#>

############################################################################################################
#AV36p
############################################################################################################

$global:sddcHostType = "AV36P"

.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 
$ExcelSheet.Range("B2") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("N2") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


### Calculate for AV36p All In Storage Only
$global:vCpuPerVM = 0
$global:vRamPerVM = 0
.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$ExcelSheet.Range("s2") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("t2") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

### Calculate for AV36p All In CPU Only
$global:vCpuPerVM = $global:vCpuPerVMBackup
$global:vRamPerVM = 0
$global:storagePerVM = 0

.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$ExcelSheet.Range("w2") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("x2") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

### Calculate for AV36p All In Memory Only
$global:vCpuPerVM = 0
$global:vRamPerVM = $global:vRamPerVMBackup
$global:storagePerVM = 0

.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$ExcelSheet.Range("u2") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("v2") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


############################################################################################################
#AV52
############################################################################################################

$global:sddcHostType = "AV52"
$global:vCpuPerVM = $global:vCpuPerVMBackup
$global:vRamPerVM = $global:vRamPerVMBackup
$global:storagePerVM = $global:storagePerVMBackup

.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 
$ExcelSheet.Range("B7") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("N7") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


### Calculate for AV52 All In Storage Only
$global:vCpuPerVM = 0
$global:vRamPerVM = 0
.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$ExcelSheet.Range("s7") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("t7") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

### Calculate for AV52 All In CPU Only
$global:vCpuPerVM = $global:vCpuPerVMBackup
$global:vRamPerVM = 0
$global:storagePerVM = 0

.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$ExcelSheet.Range("w7") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("x7") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

### Calculate for AV52 All In Memory Only
$global:vCpuPerVM = 0
$global:vRamPerVM = $global:vRamPerVMBackup
$global:storagePerVM = 0

.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body
$ExcelSheet.Range("u7") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("v7") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


############################################################################################################
#AV64
############################################################################################################

$global:sddcHostType = "AV64"
$global:vCpuPerVM = $global:vCpuPerVMBackup
$global:vRamPerVM = $global:vRamPerVMBackup
$global:storagePerVM = $global:storagePerVMBackup

.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $global:apiurlstaging -Method 'POST' -Headers $global:headers -Body $global:body 
$ExcelSheet.Range("B12") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("N12") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype


### Calculate for AV64 All In Storage Only
$global:vCpuPerVM = 0
$global:vRamPerVM = 0
.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $global:apiurlstaging  -Method 'POST' -Headers $headers -Body $body
$ExcelSheet.Range("s12") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("t12") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

### Calculate for AV64 All In CPU Only
$global:vCpuPerVM = $global:vCpuPerVMBackup
$global:vRamPerVM = 0
$global:storagePerVM = 0

.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $global:apiurlstaging  -Method 'POST' -Headers $headers -Body $body
$ExcelSheet.Range("w12") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("x12") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype

### Calculate for AV64 All In Memory Only
$global:vCpuPerVM = 0
$global:vRamPerVM = $global:vRamPerVMBackup
$global:storagePerVM = 0

.\apipost.ps1
$global:apipostresponse = Invoke-RestMethod $global:apiurlstaging  -Method 'POST' -Headers $headers -Body $body
$ExcelSheet.Range("u12") = $global:apipostresponse.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$ExcelSheet.Range("v12") = $global:apipostresponse.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype




$app.Run("LockEverything") # Run the Excel Macro in the Sizer file to import the RV Tools file.
$app.Run("MakePrimaryFinalResults") 
$app.Run("SizingPresentation")