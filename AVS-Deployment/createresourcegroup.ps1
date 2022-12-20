
$test = Get-AzResourceGroup -Name $avsrgname -ErrorAction:Ignore

if ($test.count -eq 1) {
write-Host -ForegroundColor Blue "
$avsrgname Already Exists ... Skipping to Next Step"   
}
  
if ($test.count -eq 0) {
write-host -foregroundcolor Yellow "
Creating Resource Group $avsrgname"
$command = New-AzResourceGroup -Name $avsrgname -Location $regionfordeployment
$command | ConvertTo-Json

$test = Get-AzResourceGroup -Name $avsrgname -ErrorAction:Ignore
If(test.count -eq 0){
Write-Host -ForegroundColor Red "
Resource Group $avsrgname Failed to Create"
Exit
}
else {
  write-Host -ForegroundColor Green "
Resource Group $avsrgname Successfully Created"
  }
}




