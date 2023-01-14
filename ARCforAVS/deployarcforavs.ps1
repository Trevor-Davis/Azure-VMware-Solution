#variables
$avssub = $global:avssub
$folder = $global:folder
$networkForApplianceVM = $global:networkCIDRForApplianceVM #this is NSX segment name which will be created for ARC
$networkCIDRForApplianceVM = $global:networkCIDRForApplianceVM #input the network gateway in this format, this is the network which will be created 10.1.1.1/24
$arcfoldername = "ArcOnAVS-2.0.14"

#Functions to Load
$filename = "Function-azurelogin.ps1"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/AzureScripts/main/Functions/$filename" -OutFile $env:TEMP\$folder\$filename
. $env:TEMP\$folder\$filename



#########################################################################################
azurelogin -subtoconnect $avssub

Register-AzResourceProvider -ProviderNamespace Microsoft.ConnectedVMwarevSphere 
Register-AzResourceProvider -ProviderNamespace Microsoft.ExtendedLocation
Register-AzResourceProvider -ProviderNamespace Microsoft.KubernetesConfiguration 
Register-AzResourceProvider -ProviderNamespace Microsoft.ResourceConnector 
Register-AzResourceProvider -ProviderNamespace Microsoft.AVS
Register-AzProviderPreviewFeature -Name AzureArcForAVS -ProviderNamespace Microsoft.AVS

#Download Zip
$filename = "ArcOnAVS.zip"
write-host "Downloading" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/ARCforAVS/$filename" -OutFile $env:TEMP\$folder\$filename
Expand-Archive -Path $env:TEMP\$folder\$filename -DestinationPath $env:TEMP\$folder\

$payload = @{
    "subscriptionId" = $global:avssub
    "resourceGroup" = $global:avsrgname
    "privateCloud" = $global:pcname
    "isStatic" = $true
  }
$data = @{"networkForApplianceVM" = $networkforappliancevm;"networkCIDRForApplianceVM" = $networkCIDRForApplianceVM;}

$payload.Add("staticIpNetworkDetails",$data)
$payload | ConvertTo-Json | Out-File $env:TEMP\$folder\$arcfoldername\src\config_avs.json

