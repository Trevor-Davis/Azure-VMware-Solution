##################################
#Functions to Load
################################## 
$functions = @(
'Function-createresourcegroup.ps1',
'Function-createreexpressroutegateway.ps1'
)

foreach ($function in $functions) {
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$function" -OutFile $env:TEMP\$folder\$function 
. $env:TEMP\$folder\$function
}

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
azurelogin -subtoconnect $exrgwsub

createresourcegroup -resourcegroup $avsrgname -region $regionfordeployment

##################################
#Kickoff Private Cloud Build
##################################
$filename = "deployavsprivatecloud.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename 


<#
##################################
#Create ExpressRoute Gateway (Function)
##################################
azurelogin -subtoconnect $exrgwsub

createexrgateway -vnet $exrgwvnet -resourcegroup $exrgwrg -region $exrgwregion -exrgwname $exrgwname


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