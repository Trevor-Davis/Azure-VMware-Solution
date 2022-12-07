########## Connect To Azure  #######################################
write-host -ForegroundColor Green "

Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
Connect-AzAccount -Subscription $sub 