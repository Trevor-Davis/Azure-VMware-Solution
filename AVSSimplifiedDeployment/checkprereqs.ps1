

Write-Host -ForegroundColor Blue "
Checking Pre-Requisites ... "
 
$alertarray = @()
$MinPowerShellVersion = 7.1
$MinAzPowerShellVersion = 7.1
$MinAzVMWPowerShellVersion = 0.4
$MinVMWPowerCLIVersion = 12.5
$Minvmwarepowerclihcxversion = 12.5
$global:powershell7 = "yes"
$global:count = 0

#######################################################################################
# Get PowerShell Version
#######################################################################################
$Major = ($PSVersionTable.PSVersion.Major)
$Minor = ($PSVersionTable.PSVersion.Minor)
$Version = ($Major,$Minor) -Join "."
$Version = [Decimal]"$Version"
if ($Version -lt $MinPowerShellVersion) {
Write-Host -ForegroundColor Red "Powershell Version $MinPowerShellVersion or Higher is required.
The download can be found here: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows

NOTE: This script must run using Powershell 7

"
$global:powershell7 = "no"
Exit

} 



#######################################################################################
# Get Azure PowerShell Module
#######################################################################################
$AZPSVersion = Get-InstalledModule -Name Az -ErrorAction Ignore

$Version = ($AZPSVersion.Version)
if ($Version -lt $MinAzPowerShellVersion) {
    $alertarray += "
Azure Powershell Module Needs to be Upgraded to Version $MinAzPowerShellVersion or Higher
The download can be found here: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps
"
    $global:count = $global:count + 1
}

#######################################################################################
# Get Azure VMware PowerShell Module
#######################################################################################
$AZVMWPSVersion = Get-InstalledModule -Name Az.VMware -ErrorAction Ignore

$Version = ($AZVMWPSVersion.Version)
if ($Version -lt $MinAzVMWPowerShellVersion) {
    $alertarray += "
Azure VMware Powershell Module Needs to be Upgraded to Version $MinAzVMWPowerShellVersionor or Higher
The download can be found here: https://docs.microsoft.com/en-us/powershell/module/az.vmware
"
    $global:count = $global:count + 1
}

#######################################################################################
# Get VMware PowerCLI Modules
#######################################################################################
$vmwarepowercliversion = Get-InstalledModule -Name VMware.PowerCLI -ErrorAction Ignore
$Version = ($vmwarepowercliversion.Version)
if ($Version -lt $MinVMWPowerCLIVersion) {
    $alertarray += "
VMware PowerCLI Module Needs to be Upgraded to Version $MinVMWPowerCLIVersion or Higher
The download can be found here: https://www.powershellgallery.com/packages/VMware.PowerCLI
"
    $global:count = $global:count + 1
}


$vmwarepowerclihcxversion = Get-InstalledModule -Name VMware.VimAutomation.Hcx -ErrorAction Ignore
$Version = ($vmwarepowerclihcxversion.Version)
if ($Version -lt $Minvmwarepowerclihcxversion) {
    $alertarray += "
VMware HCX PowerCLI Module Needs to be Upgraded to Version $Minvmwarepowerclihcxversion or Higher
The download can be found here: https://www.powershellgallery.com/packages/VMware.VimAutomation.Hcx
"
    $global:count = $global:count + 1
}


#######################################################################################
# Get Azure CLI Info
#######################################################################################
$programlist = @()
$programlist += Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | ForEach-Object {(($_.DisplayName))}  
$programlist  += Get-ItemProperty 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | ForEach-Object {(($_.DisplayName))}  
$checkazurecli = $programlist -match 'Microsoft Azure CLI'

If ($checkazurecli.Count -eq 0) {
    $alertarray += "
Azure CLI Needs To Be Installed
The download can be found here: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
"
    $global:count = $global:count + 1
}


Write-Host
Write-Host -ForegroundColor Red $alertarray
Write-Host

