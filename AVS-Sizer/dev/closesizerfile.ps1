## - Saving Excel file - if the file exist do delete then save
$xlsFile = $filename1;

if (Test-Path $xlsFile)
{
Remove-Item $xlsFile
$xlsObj.ActiveWorkbook.SaveAs($xlsFile);
}
else
{
$xlsObj.ActiveWorkbook.SaveAs($xlsFile);
};