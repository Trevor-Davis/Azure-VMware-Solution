########################################################################################
# Prompts user to locate the RV Tools File
########################################################################################
If ($global:testing -eq 1){
    $global:rvtoolslocation = "C:\Users\tredavis\OneDrive - Microsoft\GitHub\Azure VMware Solution\AVS-Sizer\dev\test.xlsx" #identifies the rvtools location
    $global:rvtoolsfilename = "test.xlsx" #identifies the filename of the rvtools file   
    .\variablesinventory.ps1
    Read-Host "press any key"
}
else{        


Add-Type -AssemblyName System.Windows.Forms
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.InitialDirectory = $InitialDirectory
$OpenFileDialog.ShowDialog() 
$OpenFileDialog.FileName
$global:rvtoolslocation = $OpenFileDialog.FileName #identifies the rvtools location
$global:rvtoolsfilename = $openfiledialog.SafeFileName #identifies the filename of the rvtools file

if ($global:rvtoolsfilename -eq ""){
Exit

} 

}

########################################################################################
# Opens the sizer.xlsm file and begins to write data to it.
########################################################################################
Write-Host "
Importing RVTools File..."
.\opensizerfile.ps1

$global:ExcelSheet = $ExcelWorkBook.Worksheets.Item('importsizer')
$ExcelSheet.activate()
$ExcelSheet.Range("g2") = $global:rvtoolslocation
$ExcelSheet.Range("g3") = $global:rvtoolsfilename


$ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')
$ExcelSheet.Range("a1") = "RV Tools"
$ExcelSheet.Range("B2:b33") = ""
$ExcelSheet.Range("N2:N15") = ""
$ExcelSheet.Range("b35") = $global:excludepoweredoff

$global:app.Run("Import") # Run the Excel Macro in the Sizer file to import the RV Tools file.

If ($global:excludepoweredoff -eq "Yes"){

Write-Host "
Removing Powered Off VMs ... "
Write-Host -ForegroundColor Yellow "Depending on the amount of workloads in the RVTools file this could take a few minutes"
$global:app.Run("deletepoweredoff") # If Powered Off VMs were chosen to be exlcuded, they are.
    
}


Write-Host "
Inventorying Workloads Into Windows, SQL, Linux or Other ..."
Write-Host -ForegroundColor Yellow "Depending on the amount of workloads in the RVTools file this could take a few minutes"
$global:app.Run("AssignvInfoLabels") # Run the Excel Macro in the Sizer file to label all the VMs into their categories.


.\closesizerfile.ps1

########################################################################################
# Uses the importsizer tool to read the importsizer tab from sizer.xlsm
########################################################################################
Write-Host "
Calculating AVS Private Cloud Sizes ... "

$global:importsizer = Import-Excel -Path $global:sizerlocation -WorksheetName "importsizer" 

############################################################################################################
#The following now queries the APIs to get the multiple calculations
############################################################################################################

#Values used in all calculations

$global:memoryOvercommitFactor = $global:importsizer[41].Value

############################################################################################################
#Re-Opens The Sizer.xlsm file
############################################################################################################
.\opensizerfile.ps1


$global:ExcelSheet = $ExcelWorkBook.Worksheets.Item('sizingresults')


############################################################################################################
#All In Models
############################################################################################################

#.\av36AllInSizing.ps1
.\allinsizing\av36pAllInSizing.ps1
.\allinsizing\av52AllInSizing.ps1
.\allinsizing\av64AllInSizing.ps1


 

############################################################################################################
#Windows Only Models
############################################################################################################

.\windowssizing\WindowsVariables.ps1
if ($global:totalVMCount -lt 1){

}
else {
   # .\av36WindowsSizing.ps1
    .\windowssizing\av36pWindowsSizing.ps1
    .\windowssizing\av52WindowsSizing.ps1
    .\windowssizing\av64WindowsSizing.ps1
}

############################################################################################################
#SQL Only Models
############################################################################################################


.\sqlsizing\SQLVariables.ps1
if ($global:totalVMCount -lt 1){

}
else {
    #.\av36SQLSizing.ps1
    .\sqlsizing\av36pSQLSizing.ps1
    .\sqlsizing\av52SQLSizing.ps1
    .\sqlsizing\av64SQLSizing.ps1
}

############################################################################################################
#Linux and Other 
############################################################################################################


.\linuxandothersizing\LinuxAndOtherVariables.ps1
if ($global:totalVMCount -lt 1){

}
else {
  #  .\av36LinuxAndOtherSizing.ps1
    .\linuxandothersizing\av36pLinuxAndOtherSizing.ps1
    .\linuxandothersizing\av52LinuxAndOtherSizing.ps1
    .\linuxandothersizing\av64LinuxAndOtherSizing.ps1
}
Write-Host "
Cleaning Up ... "

$app.Run("MakePrimaryFinalResults") 

$app.Run("Hide_Sheets") # Run the Excel Macro in the Sizer file to import the RV Tools file.
$app.Run("Protect") # Run the Excel Macro in the Sizer file to import the RV Tools file.
