#variables
write-host "Go Bills 20"
$sub = $global:avssub
$folder = $global:folder
$networkForApplianceVM = $global:networkForApplianceVM #this is NSX segment name which will be created for ARC
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

Set-ExecutionPolicy -Scope Process -ExecutionPolicy ByPass
Set-Location -Path $env:TEMP\ARCForAVS\ArcOnAVS-2.0.14\src
.\run.ps1 -Operation onboard -FilePath .\$env:TEMP\$folderforstaging\config_avs.json


<#
# Create JSON

#Out-File -FilePath $env:TEMP\"ARCForAVS"\"ArcOnAVS-2.0.14"\src\config_avs.json -Encoding utf8
Out-File -FilePath c:\temp\config_avs.json -Encoding utf8
$filelinearray = "{`n
""""subscriptionId"""" + " = "+ $global:avssub `n
'"resourceGroup"' =  $global:avsrgname `n
}"
$jason = $filelinearray | ConvertTo-Json
Set-Content -Value $jason -Encoding utf8 -Path c:\temp\config_avs.json

<#
+'"'+","),`
('"applianceControlPlaneIpAddress"'+":"+" "+'"'+$global:applianceControlPlaneIpAddress+'"'+","),`
('"privateCloud"'+":"+" "+'"'+$global:pcname+'"'+","),`
('"isStatic"'+":"+" true"+","),`
('"staticIpNetworkDetails"'+":"+" "+"{"),`
('"networkForApplianceVM"'+":"+" "+'"'+$global:networkforappliancevm+'"'+","),`
('"networkCIDRForApplianceVM"'+":"+" "+'"'+$global:networkCIDRForApplianceVM+'"'+","),`
('"k8sNodeIPPoolStart"'+":"+" "+'"'+$global:k8sNodeIPPoolStart+'"'+","),`
('"k8sNodeIPPoolEnd"'+":"+" "+'"'+$global:k8sNodeIPPoolEnd+'"'+","),`
('"gatewayIPAddress"'+":"+" "+'"'+$global:gatewayIPAddress+'"'),`
('}'),`
('}')

#foreach ($line in $filelinearray)
#{Add-Content -Encoding utf8 $env:TEMP\"ARCForAVS"\"ArcOnAVS-2.0.14"\src\config_avs.json -Value $line}
#{Add-Content -Encoding unicode c:\temp\config_avs.json -Value $line}

# $convertfile = Get-Content $env:TEMP\"ARCForAVS"\"ArcOnAVS-2.0.14"\src\config_avs.json | ConvertTo-Json
# Set-Content -Value $convertfile -Encoding utf8 -Path $env:TEMP\"ARCForAVS"\"ArcOnAVS-2.0.14"\src\config_avs.json
$jason = $filelinearray | ConvertTo-Json
Set-Content -Value $jason -Encoding utf8 -Path c:\temp\config_avs.json


param($subscriptionId,$resourceGroup,$applianceControlPlaneIpAddress,$privateCloud,$isStatic)

$payload = @{
    "subscriptionId" = $global:avssub
    "resourceGroup" = $global:avsrgname
    "applianceControlPlaneIpAddress" = $global:applianceControlPlaneIpAddress
    "privateCloud" = $global:pcname
    "isStatic" = $true
  }
$data = @{"networkForApplianceVM" = $networkforappliancevm;"networkCIDRForApplianceVM" = $networkCIDRForApplianceVM;"k8sNodeIPPoolStart" = $global:k8sNodeIPPoolStart;"k8sNodeIPPoolEnd" = $global:k8sNodeIPPoolEnd;"gatewayIPAddress" = $global:gatewayIPAddress}

$payload.Add("staticIpNetworkDetails",$data)
$payload | ConvertTo-Json | Out-File $env:TEMP\"ARCForAVS"\"ArcOnAVS-2.0.14"\src\config_avs.json -Encoding utf8



$payload = @{
    "subscriptionId" = $global:avssub
    "resourceGroup" = $global:avsrgname
    "applianceControlPlaneIpAddress" = $global:applianceControlPlaneIpAddress
    "privateCloud" = $global:pcname
    "isStatic" = $true
  }
$data = @{"networkForApplianceVM" = $networkforappliancevm;"networkCIDRForApplianceVM" = $networkCIDRForApplianceVM;"k8sNodeIPPoolStart" = $global:k8sNodeIPPoolStart;"k8sNodeIPPoolEnd" = $global:k8sNodeIPPoolEnd;"gatewayIPAddress" = $global:gatewayIPAddress}

$payload.Add("staticIpNetworkDetails",$data)
$payload | ConvertTo-Json | Out-File $env:TEMP\"ARCForAVS"\"ArcOnAVS-2.0.14"\src\config_avs.json
#>

