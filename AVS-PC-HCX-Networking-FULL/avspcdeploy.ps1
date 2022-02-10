$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/ConnectToAzure.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
<#$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/validatesubready.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/DefineResourceGroup.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/kickoffdeploymentofavsprivatecloud.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/ConnectAVSExrToVnet.ps1
#>
Invoke-Expression $($ScriptFromGitHub.Content)
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/ConnectAVSExrToOnPremExr.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/addhcx.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
