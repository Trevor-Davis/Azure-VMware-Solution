Write-Host "Checking For Import-Excel Module"

$check = Get-InstalledModule -Name ImportExcel
$check
if($check.version -le 7.8){
Write-Host "Installing ImportExcel PowerShell Module ... "
Install-Module -Name ImportExcel -Force}
else {
Write-Host "Import-Excel Modeule Is Installed"
}