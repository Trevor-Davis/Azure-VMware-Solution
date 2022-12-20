    $sublist = @()
    $sublist = Get-AzSubscription -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    $checksub = $sublist -match $avssub
    $getazcontext = Get-AzContext
    
If ($checksub.Count -eq 1 -and $getazcontext.Subscription.Id -eq $avssub) {
Write-host -foregroundcolor Blue "
$avssub Connected ... Skipping to Next Step"}

if ($checksub.Count -eq 1 -and $getazcontext.Subscription.Id -ne $avssub) {
Set-AzContext -SubscriptionId $sub -WarningAction SilentlyContinue
write-host -foregroundcolor Blue "
$avssub Connected ... Skipping to Next Step"}

if ($checksub.Count -eq 0) {
write-host -ForegroundColor Green "
Connecting to your Azure Subscription $avssub ... there should be a web browser pop-up ... go there to login"
Connect-AzAccount -Subscription $avssub -WarningAction SilentlyContinue
}