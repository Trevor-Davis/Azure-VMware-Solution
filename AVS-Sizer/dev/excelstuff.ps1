


$check = Get-InstalledModule -Name ImportExcel
$check
if($check.version -le 7.8){Install-Module -Name ImportExcel -Force}


$filename = "sizer.xlsm" # this is the filename of the sizer file
$apiurl = "https://vmc.vmware.com/api/vmc-sizer/v5/recommendation?vmPlacement=false"



$test = 0
if ($test -eq 1){
$global:sizerlocation = "C:\Users\tredavis\OneDrive - Microsoft\GitHub\Azure VMware Solution\AVS-Sizer\dev" + "\" + $filename # this is the full path of the sizer file location
$locationofpowershell = "C:\Users\tredavis\OneDrive - Microsoft\GitHub\Azure VMware Solution\AVS-Sizer\dev"
}
else {
    $PSScriptRoot = $locationofpowershell
    $global:sizerlocation = $locationofpowershell + "\" + $filename # this is the full path of the sizer file location
}




if($test = 1){
$rvtoolsfilename = "Z3-AVS-VC-RVTools_export_all_2023-09-08_14.05.03.xlsx"
$rvtoolslocation = "C:\Users\tredavis\OneDrive - Microsoft\Customers\Eli Lilly\Z3-AVS-VC-RVTools_export_all_2023-09-08_14.05.03.xlsx"
}
else{

$wshell = New-Object -ComObject Wscript.Shell #This throws an alert to locate the RV Tools file
$answer = $wshell.Popup("Locate the RVTools file to be assessed",0,"Azure VMware Solution Sizer - Trevor Davis",1)
if($answer -eq 2){Break} #Will break out of script if users cancels in previous step

Add-Type -AssemblyName System.Windows.Forms
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.InitialDirectory = $InitialDirectory
$OpenFileDialog.ShowDialog() 
$OpenFileDialog.FileName
$rvtoolslocation = $OpenFileDialog.FileName #identifies the rvtools location
$rvtoolsfilename = $openfiledialog.SafeFileName #identifies the filename of the rvtools file
$rvtoolslocation
$rvtoolsfilename
}

. $locationofpowershell\opensizerfile.ps1


$excel = $excel.Sheets.Item("importsizer") #Brings the sizer file the starting page
$excel.Range("G2") = $rvtoolslocation #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$excel.Range("G3") = $rvtoolsfilename #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
$app = $excel.Application 
$app.Run("Import") # Run the Excel Macro in the Sizer file to import the RV Tools file.
$app.Run("AssignvInfoLabels") # Run the Excel Macro in the Sizer file to create the vInfo Tab for Windows VMs


$workbook.Save()
$workbook.Close()
$excel.Quit
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)    



$importsizer = Import-Excel -Path $sizerlocation -WorksheetName "importsizer" 
$importsizer


############################################################################################################
#Variables which will apply to all models
############################################################################################################
$global:compressionRatio = $importsizer[38].Value
$global:computeOvercommitFactor = $importsizer[39].Value
$global:vCpuPerCore = $importsizer[39].Value
$global:fttFtmType = $importsizer[40].Value
$global:memoryOvercommitFactor = $importsizer[41].Value

if ($test = 1){
Write-Host $global:compressionRatio 
Write-Host $global:computeOvercommitFactor
Write-Host $global:vCpuPerCore
Write-Host $global:fttFtmType
}


############################################################################################################
#All In Models
############################################################################################################
$global:totalVMCount = $importsizer[0].Value
$global:vCpuPerVM = $importsizer[1].Value
$global:storagePerVM = $importsizer[3].Value*1000
$global:vRamPerVM = $importsizer[5].Value

if ($test = 1){
    Write-Host $global:totalVMCount
    Write-Host $global:vCpuPerVM
    Write-Host $global:storagePerVM
    Write-Host $global:vRamPerVM
    $global:sddcHostType = $importsizer[35].Value
    Write-Host $global:sddcHostType
     }


### Calculate for AV36 All In
$global:sddcHostType = $importsizer[35].Value
. $locationofpowershell\apipost.ps1
$global:response36AllIn = Invoke-RestMethod "https://vmc.vmware.com/api/vmc-sizer/v5/recommendation?vmPlacement=false" -Method 'POST' -Headers $headers -Body $body 

### Calculate for AV36p All In
$global:sddcHostType = $importsizer[36].Value
. $locationofpowershell\apipost.ps1
$global:response36pAllIn = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 

### Calculate for AV52 All In
$global:sddcHostType = $importsizer[37].Value
. $locationofpowershell\apipost.ps1
$global:response52AllIn = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 


############################################################################################################
#Windows Only Models
############################################################################################################
$global:totalVMCount = $importsizer[7].Value
$global:vCpuPerVM = $importsizer[8].Value
$global:storagePerVM = $importsizer[10].Value*1000
$global:vRamPerVM = $importsizer[12].Value

### Calculate for AV36 Windows
$global:sddcHostType = $importsizer[35].Value
. $locationofpowershell\apipost.ps1
$global:response36Windows = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 

### Calculate for AV36p Windows
$global:sddcHostType = $importsizer[36].Value
. $locationofpowershell\apipost.ps1
$global:response36pWindows = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 

### Calculate for AV52 Windows
$global:sddcHostType = $importsizer[37].Value
. $locationofpowershell\apipost.ps1
$global:response52Windows = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 



############################################################################################################
#SQL Only Models
############################################################################################################
$global:totalVMCount = $importsizer[14].Value
$global:vCpuPerVM = $importsizer[15].Value
$global:storagePerVM = $importsizer[17].Value*1000
$global:vRamPerVM = $importsizer[19].Value

### Calculate for AV36 SQL
$global:sddcHostType = $importsizer[35].Value
. $locationofpowershell\apipost.ps1
$global:response36SQL = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 

### Calculate for AV36p SQL
$global:sddcHostType = $importsizer[36].Value
. $locationofpowershell\apipost.ps1
$global:response36pSQL = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 

### Calculate for AV52 SQL
$global:sddcHostType = $importsizer[37].Value
. $locationofpowershell\apipost.ps1
$global:response52SQL = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 


############################################################################################################
#Linux Only Models
############################################################################################################
$global:totalVMCount = $importsizer[21].Value
$global:vCpuPerVM = $importsizer[22].Value
$global:storagePerVM = $importsizer[24].Value*1000
$global:vRamPerVM = $importsizer[26].Value

### Calculate for AV36 Linux
$global:sddcHostType = $importsizer[35].Value
. $locationofpowershell\apipost.ps1
$global:response36Linux = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 

### Calculate for AV36p Linux
$global:sddcHostType = $importsizer[36].Value
. $locationofpowershell\apipost.ps1
$global:response36pLinux = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 

### Calculate for AV52 Linux
$global:sddcHostType = $importsizer[37].Value
. $locationofpowershell\apipost.ps1
$global:response52Linux = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 


############################################################################################################
#Other Only Models
############################################################################################################
$global:totalVMCount = $importsizer[21].Value
$global:vCpuPerVM = $importsizer[22].Value
$global:storagePerVM = $importsizer[24].Value*1000
$global:vRamPerVM = $importsizer[26].Value

### Calculate for AV36 Other
$global:sddcHostType = $importsizer[35].Value
. $locationofpowershell\apipost.ps1
$global:response36Other = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 

### Calculate for AV36p Other
$global:sddcHostType = $importsizer[36].Value
. $locationofpowershell\apipost.ps1
$global:response36pOther = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 

### Calculate for AV52 Other
$global:sddcHostType = $importsizer[37].Value
. $locationofpowershell\apipost.ps1
$global:response52Other = Invoke-RestMethod $apiurl -Method 'POST' -Headers $headers -Body $body 


############################################################################################################
#Results
############################################################################################################

###Results 36p

$hostcount36pAllIn = $response36pAllIn.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid36pAllIn = $response36pAllIn.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV36p Host Count All In: $hostcount36pAllIn ($fttraid36pAllIn)"

$hostcount36pWindows = $response36pWindows.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid36pWindows = $response36pWindows.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV36p Host Count Windows: $hostcount36pWindows ($fttraid36pWindows)"

$hostcount36pSQL = $response36pSQL.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid36pSQL = $response36pSQL.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV36p Host Count SQL: $hostcount36pSQL ($fttraid36pSQL)"

$hostcount36pLinux = $response36pLinux.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid36pLinux = $response36pLinux.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV36p Host Count Linux: $hostcount36pLinux ($fttraid36pLinux)"

$hostcount36pOther = $response36pOther.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid36pOther = $response36pOther.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV36p Host Count Other: $hostcount36pOther ($fttraid36pOther)"

###Results 52

$hostcount52AllIn = $response52AllIn.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid52AllIn = $response52AllIn.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV52 Host Count All In: $hostcount52AllIn ($fttraid52AllIn)"

$hostcount52Windows = $response52Windows.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid52Windows = $response52Windows.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV52 Host Count Windows: $hostcount52Windows ($fttraid52Windows)"

$hostcount52SQL = $response52SQL.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid52SQL = $response52SQL.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV52 Host Count SQL: $hostcount52SQL ($fttraid52SQL)"

$hostcount52Linux = $response52Linux.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid52Linux = $response52Linux.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV52 Host Count Linux: $hostcount52Linux ($fttraid52Linux)"

$hostcount52Other = $response52Other.sddclist.clusterList.sazClusters.hostbreakuplist.totalHostCount
$fttraid52Other = $response52Other.sddclist.clusterlist.sazclusters.clusterInfoList.fttFtmType
Write-Host "AV52 Host Count Other: $hostcount52Other ($fttraid52Other)"


###Write Results to Excel

. $locationofpowershell\opensizerfile.ps1

$excel = $excel.Sheets.Item("sizingresults") #Brings the sizer file the starting page
$excel.Range("B2") = $hostcount36pAllIn #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$excel.Range("B3") = $hostcount52AllIn #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
$excel.Range("B4") = $hostcount36pWindows #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$excel.Range("B5") = $hostcount52Windows #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
$excel.Range("B6") = $hostcount36pSQL #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$excel.Range("B7") = $hostcount52SQL #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
$excel.Range("B8") = $hostcount36pLinux #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$excel.Range("B9") = $hostcount52Linux #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
$excel.Range("B10") = $hostcount36pOther #writes the rvtools file path and filename to the sizer sheet so the excel macro knows where it's located.
$excel.Range("B11") = $hostcount52Other #writes the rvtools filename to the sizer sheet so the excel macro knows where it's located.
#>







<#
$wshell = New-Object -ComObject Wscript.Shell #This throws an alert to close the files
$answer = $wshell.Popup(
"The SIZER file and RVTOOLS file must be Closed

Please Close Those Files Before Continuing",0,"Azure VMware Solution Sizer - Trevor Davis",1)
if($answer -eq 2){Break} #Will break out of script if users cancels in previous step

#>