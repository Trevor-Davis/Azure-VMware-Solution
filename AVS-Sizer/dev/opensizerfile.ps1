#start Excel 

$global:ExcelObj = New-Object -comobject Excel.Application
$ExcelObj.visible=$true
$global:ExcelWorkBook = $ExcelObj.Workbooks.Open($global:sizerlocation) # open the sizer file
$global:app = $ExcelObj.Application 
$global:app.Run("UnProtect") # Run the Excel Macro in the Sizer file to label all the VMs into their categories.
$global:app.Run("Unhide_All_Sheets") # Run the Excel Macro in the Sizer file to import the RV Tools file.

