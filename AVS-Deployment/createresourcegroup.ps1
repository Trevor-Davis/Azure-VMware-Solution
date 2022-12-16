
$test = Get-AzResourceGroup -Name $rgname -ErrorAction:Ignore

if ($test.count -eq 1) {
write-Host -ForegroundColor Blue "
$rgname Already Exists ... Skipping to Next Step"   
}
  
if ($test.count -eq 0) {
write-host -foregroundcolor Yellow "
Creating Resource Group $rgname"
$command = New-AzResourceGroup -Name $rgname -Location $regionfordeployment
$command | ConvertTo-Json

$test = Get-AzResourceGroup -Name $rgname -ErrorAction:Ignore
If(test.count -eq 0){
Write-Host -ForegroundColor Red "
Resource Group $rgname Failed to Create"
Exit
}
else {
  write-Host -ForegroundColor Green "
Resource Group $rgname Successfully Created"
  }
}




