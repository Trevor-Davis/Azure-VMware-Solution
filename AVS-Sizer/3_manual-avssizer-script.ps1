$global:manualsizing = 1
########################################################################################
# Opens the sizer.xlsm file and begins to write data to it.
########################################################################################

.\opensizerfile.ps1

$global:ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.activate()

$ExcelSheet.Range("B2:b33") = ""
$ExcelSheet.Range("N2:N15") = ""
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

#Values used in all calculations
$global:memoryOvercommitFactor = 1

############################################################################################################
#AV36p
############################################################################################################
$global:sddcHostType = "AV36P"
.\apipost.ps1
$global:response36pAllIn = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 
$global:hostcount36pAllIn = $global:response36pAllIn.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraid36pAllIn = $global:response36pAllIn.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype
$ExcelSheet.Range("B2") = $global:hostcount36pAllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N2") = $global:fttraid36pAllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.

############################################################################################################
#AV52
############################################################################################################
$global:sddcHostType = "AV52"
.\apipost.ps1
$global:responseAV52AllIn = Invoke-RestMethod $global:apiurl -Method 'POST' -Headers $global:headers -Body $global:body 
$global:hostcountAV52AllIn = $global:responseAV52AllIn.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV52AllIn = $global:responseAV52AllIn.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype
$ExcelSheet.Range("B7") = $global:hostcountAV52AllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N7") = $global:fttraidAV52AllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.

############################################################################################################
#AV64
############################################################################################################
$global:sddcHostType = "AV64"
.\apipost.ps1
$global:responseAV64AllIn = Invoke-RestMethod $global:apiurlstaging -Method 'POST' -Headers $global:headers -Body $global:body 
$global:hostcountAV64AllIn = $global:responseAV64AllIn.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$global:fttraidAV64AllIn = $global:responseAV64AllIn.sddclist.clusterList.sazClusters.clusterInfoList.fttFTMtype
$ExcelSheet.Range("B12") = $global:hostcountAV64AllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$ExcelSheet.Range("N12") = $global:fttraidAV64AllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.

$app.Run("Hide_Sheets") # Run the Excel Macro in the Sizer file to import the RV Tools file.
$app.Run("Protect") # Run the Excel Macro in the Sizer file to import the RV Tools file.
 
$app.Run("MakePrimaryFinalResults") 