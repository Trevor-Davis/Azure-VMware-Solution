$filename = "azurelogin-function.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" `
-OutFile $env:TEMP\AVSDeploy\$filename

. $env:TEMP\AVSDeploy\$filename


if ($buildhol_ps1 -notmatch "Yes" -and $avsdeploy_ps1 -notmatch "Yes"){
  Write-Host "No"
    $sub = "abf039b4-3e19-40ad-a85e-93937bd8a4bc"
    $pcname =""
    $pcresourcegroup =""    
    $authkeyname =""
}

Write-Host -ForegroundColor Yellow "
Generating AVS ExpressRoute Auth Key..."

$exrauthkey = New-AzVMWareAuthorization -Name $authkeyname -PrivateCloudName $pcname -ResourceGroupName $pcresourcegroup -SubscriptionId $sub
if ($exrauthkey.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of the AVS ExR Auth Key Failed"
$failed = "Yes"
Exit
}

Write-Host -ForegroundColor Green "
AVS ExpressRoute Auth Key Generated"
  
  
