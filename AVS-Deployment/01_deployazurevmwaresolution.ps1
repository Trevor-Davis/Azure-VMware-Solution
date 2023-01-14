##################################
#Functions to Load
################################## 
<#
$filename = "Function-azurelogin.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename
#>


$filename = "Function-createreexpressroutegateway.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename

##################################
#Register Resource Provider
##################################
$filename = "registeravsresourceprovider.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename

##################################  
#Create Resource Group (Function)
##################################
$filename = "createresourcegroup.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename

##################################
#Kickoff Private Cloud Build
##################################
$filename = "deployavsprivatecloud.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename 

##################################
#Create ExpressRoute Gateway (Function)
##################################
azurelogin -subtoconnect $exrgwsub
$test = Get-AzVirtualNetworkGateway -ResourceGroupName $exrgwrg -Name $exrgwname

if ($test.count -eq 1){Write-Host -ForegroundColor Blue "
ExpressRoute Gateway $exrgwname Already Exists"
}
if ($test.count -eq 0){
createexrgateway -vnet $exrgwvnet -resourcegroup $exrgwrg -region $exrgwregion -exrgwname $exrgwname
}
<#
##################################
#Connect AVS to ExR GW
##################################
$filename = "connectavstoexrgw.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename 

##################################
#Connect AVS to On-Prem ExR
##################################
$filename = "ConnecrtAVStoOnPremExR.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename 

#>