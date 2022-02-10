$deployvariablesvariables = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/avspcdeploy-variables.ps1
Invoke-Expression $($deployvariablesvariables.Content)

write-host -ForegroundColor Yellow "
Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
Connect-AzAccount -Subscription $sub
write-host -ForegroundColor Green "
Azure Login Successful
"
 