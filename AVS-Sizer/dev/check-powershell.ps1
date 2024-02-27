Write-Host "Checking For PowerShell 7.3 or Above"

$MinPowerShellVersion = 7.3

$Major = ($PSVersionTable.PSVersion.Major)
$Minor = ($PSVersionTable.PSVersion.Minor)
$Version = ($Major,$Minor) -Join "."
$Version = [Decimal]"$Version"
if ($Version -lt $MinPowerShellVersion) {
Write-Host -ForegroundColor Red "
Powershell Version $MinPowerShellVersion or Higher is required.
The download can be found here: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows

"
Exit

} 
else {
    Write-Host "PowerShell Is Version 7.3 Or Above"
    }