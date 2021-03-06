$filename = "azurelogin-function.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" `
-OutFile $env:TEMP\AVSDeploy\$filename

. $env:TEMP\AVSDeploy\$filename


if ($buildhol_ps1 -notmatch "Yes" -and $avsdeploy_ps1 -notmatch "Yes"){

  $OnPremExRCircuitSub = ""
  $NameOfOnPremExRCircuit = ""
  $RGofOnPremExRCircuit = ""
  $exrcircuitauthname = ""
  $pcname = ""
  $pcresourcegroup = ""
  $grconnectionname = ""
}

# $OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit

#######################################################################################
# Generate Auth Key in on prem ExR Circuit
#######################################################################################
az login 
az account set --subscription $OnPremExRCircuitSub

$status = az network express-route auth show --resource-group $RGofOnPremExRCircuit --circuit-name $NameOfOnPremExRCircuit --name $exrcircuitauthname --query 'name'

if ($status.count -eq 1) {write-Host -ForegroundColor Blue "
On-Premises ExpressRoute Authorization Key Already Generated, Skipping To Next Step..."
    }
  
    else {

        az account set --subscription $OnPremExRCircuitSub
        az network express-route auth create --circuit-name $NameOfOnPremExRCircuit --resource-group $RGofOnPremExRCircuit --name $exrcircuitauthname
        
    }

      #  Set-AzExpressRouteCircuit -ExpressRouteCircuit $OnPremExRCircuit

  
    Write-Host -ForegroundColor Green "
Success: Auth Key Generated for AVS On Express Route $NameOfOnPremExRCircuit"


#######################################################################################
# Connect on-prem Circuit
#######################################################################################
Write-Host -ForegroundColor Yellow "
Connecting the $pcname Private Cloud to On-Premises via Global Reach... " 

  $OnPremCircuitAuth = az network express-route auth show --resource-group $RGofOnPremExRCircuit --circuit-name $NameOfOnPremExRCircuit --name $exrcircuitauthname --query 'authorizationKey'
  $OnPremCircuitAuth = $OnPremCircuitAuth -replace '"',""

  $command = New-AzVMwareGlobalReachConnection -Name $grconnectionname -PrivateCloudName $pcname -ResourceGroupName $pcresourcegroup -AuthorizationKey $OnPremCircuitAuth -PeerExpressRouteResourceId $OnPremExRCircuit.Id
  
  if ($command.ProvisioningState -notlike "Succeeded"){Write-Host -ForegroundColor Red "Creation of the AVS Global Reach Connection Failed"
  $failed = "Yes"        
  Exit
}
    
  Write-Host -ForegroundColor Green "
  Success: AVS Private Cloud $pcname is Connected via Global Reach to $NameOfOnPremExRCircuit"
