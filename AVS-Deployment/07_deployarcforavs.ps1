#variables
$avssub = $global:avssub
$avsrg = $global:avsrgname
$folder = $global:folder
$pcname = $global:pcname
$networkCIDRForApplianceVM = $global:networkCIDRForApplianceVM #input the network gateway in this format, this is the network which will be created 10.1.1.1/24
$tenant = ""



#DO NOT MODIFY BELOW THIS LINE #################################################

#Functions To Load

$filename = "Function-CheckForFileAndDelete.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Scripts/main/Functions/$filename" -OutFile $env:TEMP\$filename
. $env:TEMP\$filename

#Azure Login

$filename = "Function-azurelogin.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$filename
. $env:TEMP\$filename

if ($tenanttoconnect -ne "") {
  azurelogin -subtoconnect $sub -tenanttoconnect $tenant
}
else {
  azurelogin -subtoconnect $sub 
}

#Execution

azurelogin -subtoconnect $sub

Write-Host -ForegroundColor Yellow "Registering ARC for AVS Resource Providers"

Register-AzResourceProvider -ProviderNamespace Microsoft.ConnectedVMwarevSphere 
Register-AzResourceProvider -ProviderNamespace Microsoft.ExtendedLocation
Register-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration 
Register-AzResourceProvider -ProviderNamespace Microsoft.ResourceConnector 
Register-AzResourceProvider -ProviderNamespace Microsoft.AVS
Register-AzProviderPreviewFeature -Name AzureArcForAVS -ProviderNamespace Microsoft.AVS
Register-AzProviderPreviewFeature -Name earlyAccess -ProviderNamespace Microsoft.AVS


#Download Zip
$filename = "v2.0.14.zip"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://github.com/Azure/ArcOnAVS/archive/refs/tags/$filename" -OutFile $env:TEMP\$filename
mkdir $env:TEMP\"ARCForAVS" -ErrorAction:Ignore
Expand-Archive -Path $env:TEMP\$filename -DestinationPath $env:TEMP\"ARCForAVS" -Force

# checkfileanddelete -filetodelete $env:TEMP\$folderforstaging\config_avs.json

# Create JSON

#Out-File -FilePath $env:TEMP\"ARCForAVS"\"ArcOnAVS-2.0.14"\src\config_avs.json -Encoding utf8
Out-File -FilePath $env:TEMP\config_avs.json -Encoding utf8
$myjsonfile = "$env:TEMP\config_avs.json"

#$jason = $filelinearray | ConvertTo-Json

Add-Content -Value ("{") -Encoding utf8 -Path $myjsonfile
Add-Content -Value ('"subscriptionId"'+":"+" "+'"'+$avssub+'"'+",") -Encoding utf8 -Path $myjsonfile
Add-Content -Value ('"resourceGroup"'+":"+" "+'"'+$avsrg+'"'+",") -Encoding utf8 -Path $myjsonfile
Add-Content -Value ('"privateCloud"'+":"+" "+'"'+$pcname+'"'+",") -Encoding utf8 -Path $myjsonfile
Add-Content -Value ('"isStatic": true,') -Encoding utf8 -Path $myjsonfile
Add-Content -Value ('"staticIpNetworkDetails": {') -Encoding utf8 -Path $myjsonfile
Add-Content -Value ('"networkForApplianceVM"'+":"+" "+'"ARCForAVSSegment"'+",") -Encoding utf8 -Path $myjsonfile
Add-Content -Value ('"networkCIDRForApplianceVM"'+":"+" "+'"'+$networkCIDRForApplianceVM+'"') -Encoding utf8 -Path $myjsonfile
Add-Content -Value ("}") -Encoding utf8 -Path $myjsonfile
Add-Content -Value ("}") -Encoding utf8 -Path $myjsonfile

#Set-ExecutionPolicy -Scope Process -ExecutionPolicy ByPass
#Set-Location -Path $env:TEMP\ARCForAVS\ArcOnAVS-2.0.14\src
#.\run.ps1 -Operation onboard -FilePath $global:myjsonfile

