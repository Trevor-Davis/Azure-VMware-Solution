$filename = "myscripts.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/scripts/main/$filename" -OutFile $env:TEMP\AVSDeploy\$filename
. $env:TEMP\AVSDeploy\$filename


if ($skipvariables -notlike "Yes")
{
##########################################################
# ENTER VARIABLES HERE - DO NOT MODIFY ANY OTHER LINES
##########################################################
    $sub = "3988f2d0-8066-42fa-84f2-5d72f80901da" #the sub where AVS will be deployed
    $regionfordeployment = "westus" #what region do you plan on deploying AVS?
##########################################################
}

azurelogin -subtoconnect $sub

Write-Host -ForegroundColor Yellow  "
Validating Subscription Readiness ..." 
$quota = Test-AzVMWareLocationQuotaAvailability -Location $regionfordeployment -SubscriptionId $sub -ErrorAction Stop
if ("Enabled" -eq $quota.Enabled)
{

Write-Host -ForegroundColor Green "
AVS Quota is Enabled on Subscription"    

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