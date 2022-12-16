    $sublist = @()
    $sublist = Get-AzSubscription -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    $checksub = $sublist -match $sub
    $getazcontext = Get-AzContext
    
If ($checksub.Count -eq 1 -and $getazcontext.Subscription.Id -eq $sub) {
Write-host -foregroundcolor Blue "
$sub Connected ... Skipping to Next Step"}

if ($checksub.Count -eq 1 -and $getazcontext.Subscription.Id -ne $sub) {
Set-AzContext -SubscriptionId $sub -WarningAction SilentlyContinue
write-host -foregroundcolor Blue "
$sub Connected ... Skipping to Next Step"}

if ($checksub.Count -eq 0) {
write-host -ForegroundColor Green "
Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
Connect-AzAccount -Subscription $sub -WarningAction SilentlyContinue
}