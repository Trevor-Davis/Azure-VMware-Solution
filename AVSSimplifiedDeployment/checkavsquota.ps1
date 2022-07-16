<#
$pcname = ""
$rgfordeployment = ""
$sub = ""
$filename = "azureloginfunction.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVSSimplifiedDeployment/$filename" -OutFile $env:TEMP\AVSDeploy\$filename

. $env:TEMP\AVSDeploy\$filename
#>

azurelogin -subtoconnect $sub

$testforpc = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment -ErrorAction SilentlyContinue
if ($testforpc.count -eq 1) {
  $pcdeployed=1
}

if ($pcdeployed -eq 0){
Write-Host -ForegroundColor Yellow  "
Validating Subscription Readiness ..." 
$quota = Test-AzVMWareLocationQuotaAvailability -Location $regionfordeployment -SubscriptionId $sub -ErrorAction Stop
if ("Enabled" -eq $quota.Enabled)
{

Write-Host -ForegroundColor Green "
Success: Quota is Enabled on Subscription"    

}

Else

{
Write-Host -ForegroundColor Red "
Subscription $sub Does NOT Have Quota for Azure VMware Solution, please visit the following site for guidance on how to get this service enabled for your subscription."

Write-Host -ForegroundColor White "
https://docs.microsoft.com/en-us/azure/azure-vmware/enable-azure-vmware-solution
"

Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit $quickeditsettingatstartofscript.QuickEdit

Exit

}

}