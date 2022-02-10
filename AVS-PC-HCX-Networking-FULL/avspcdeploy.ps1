$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/ConnectToAzure.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
<#$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/validatesubready.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/DefineResourceGroup.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/kickoffdeploymentofavsprivatecloud.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/ConnectAVSExrToVnet.ps1
#>
Invoke-Expression $($ScriptFromGitHub.Content)
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/ConnectAVSExrToOnPremExr.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/scripts/main/AVS%20Private%20Cloud%20Deployment/addhcx.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
