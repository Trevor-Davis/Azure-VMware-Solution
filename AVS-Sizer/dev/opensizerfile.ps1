
#start Excel 
$global:excel = New-Object -ComObject Excel.Application  
$global:excel.Visible = $true  
$global:workbook = $excel.Workbooks.Open($sizerlocation) # open the sizer file

