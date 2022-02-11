remove-item $env:TEMP\AVSDeploy\*.*
mkdir $env:TEMP\AVSDeploy


#######################################################################################
# Check for Installs
#######################################################################################
Write-Host "Is Azure CLI Installed On This Machine? (Y/N)"

$azurecliyesorno = Read-Host
if ("n" -eq $azurecliyesorno) {
    Write-Host -ForegroundColor Red "The Azure CLI Installer Will Download and Auto Install, After The Installation You MUST Reboot Your Computer"
    Write-Host -ForegroundColor Yellow "Would You Like To Install Azure CLI? (Y/N)"
    $begin = Read-Host

    if ("y" -eq $begin ) {
      Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile $env:TEMP\AVSDeploy\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi'
      Write-Host -ForegroundColor Green "Azure CLI Installed"
      Write-Host -ForegroundColor Red "YOU MUST REBOOT AND THEN RE-RUN THE SCRIPT"
      Exit-PSSession
    }
    Exit-PSSession

  }
    
  $vmwareazcheck = Find-Module -Name Az.VMware
  if ($vmwareazcheck.Name -ne "Az.VMware") {
    Write-Host -ForegroundColor Yellow "Installing Azure Powershell Module ..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Install-Module -Name Az.VMware -Scope CurrentUser -Repository PSGallery -Force
    Write-Host -ForegroundColor Green "Success: Azure Powershell Module Installed"
  }

if ($PSVersionTable.PSVersion.Major -lt 7){
    Write-Host -ForegroundColor Yellow "Upgrading Powershell..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
    Write-Host -ForegroundColor Green "Success: PowerShell Upgraded"
  }
  
  $vmwarepowerclicheck = Find-Module -Name VMware.PowerCLI
  if ($vmwarepowerclicheck.Name -ne "VMware.PowerCLI") {
    Write-Host -ForegroundColor Yellow "Installing VMware.PowerCLI Module..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Install-Module -Name VMware.PowerCLI -Force
    Write-Host -ForegroundColor Green "Success: VMware.PowerCLI Module Installed"
  }
    

  
  $vmwarepowerclicheck = Find-Module -Name VMware.VimAutomation.Hcx
  if ($vmwarepowerclicheck.Name -ne "VMware.VimAutomation.Hcx") {
    Write-Host -ForegroundColor Yellow "VMware.VimAutomation.Hcx Module..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Install-Module -Name VMware.VimAutomation.Hcx -Force
    Write-Host -ForegroundColor Green "Success: VMware.VimAutomation.Hcx Module Installed"
  }
    
$filename = "ConnectToAzure.ps1"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
. "$env:TEMP\AVSDeploy\$filename"

$filename = "validatesubready.ps1"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
. "$env:TEMP\AVSDeploy\$filename"

$filename = "DefineResourceGroup.ps1"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
. "$env:TEMP\AVSDeploy\$filename"

$filename = "kickoffdeploymentofavsprivatecloud.ps1"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
. "$env:TEMP\AVSDeploy\$filename"

$filename = "ConnectAVSExrToVnet.ps1"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
. "$env:TEMP\AVSDeploy\$filename"

$filename = "ConnectAVSExrToOnPremExr.ps1"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
. "$env:TEMP\AVSDeploy\$filename"

$filename = "addhcx.ps1"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/$filename -OutFile $env:TEMP\AVSDeploy\$filename
. "$env:TEMP\AVSDeploy\$filename"

