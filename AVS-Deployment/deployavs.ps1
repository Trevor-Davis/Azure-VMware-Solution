# This function will allow for the input excel file to be defined

Function Get-FileName($initialDirectory)
{
    Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = "Please Select File"
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    # Out-Null supresses the "OK" after selecting the file.
    $OpenFileDialog.ShowDialog() | Out-Null
    $Global:SelectedFile = $OpenFileDialog.FileName
}

#Prompt the user to locate the excel input file.
Add-Type -AssemblyName PresentationCore,PresentationFramework
$ButtonType = [System.Windows.MessageBoxButton]::YesNo
$MessageboxTitle = "AVS Simplified Deployment"
$Messageboxbody = "You will need to locate the COMPLETED 'AVSSimplifiedDeployment.xlsx file.

Would You Like To Continue?
"
$MessageIcon = [System.Windows.MessageBoxImage]::Warning
$result = [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$messageicon)

if ($result -eq "Yes")
{
Get-FileName
}

if ($result -eq "No")
{
Exit
}

#Read in the excel variables

$file = $Global:SelectedFile

$sheetName = "Variables"

#create new excel COM object
$excel = New-Object -com Excel.Application

#open excel file
$wb = $excel.workbooks.open($file)

#select excel sheet to read data
$sheet = $wb.Worksheets.Item($sheetname)

$global:avssub = $sheet.Cells.Item(1,2).Text #Sub Where to Deploy AVS
$global:regionfordeployment = $sheet.Cells.Item(2,2).Text #The region where AVS should be deployed
$global:avsrgname = $sheet.Cells.Item(3,2).Text #The REsource Group To Deploy AVS, Can be New or Existing
$global:pcname = $sheet.Cells.Item(4,2).Text #The name of the AVS Private Cloud
$global:avsaddressblock = $sheet.Cells.Item(5,2).Text 
$global:avssku = $sheet.Cells.Item(6,2).Text 
$global:OnPremConnectivity = $sheet.Cells.Item(7,2).Text  #Options are ExpressRoute, VPN, None
$global:exrgwneworexisting = $sheet.Cells.Item(8,2).Text  # Set to 'New' if you are creating a new ExpressRoute Gateway for AVS, Set to 'Existing' if an existing ExpressRoute Gateway will be used.
$global:OnPremExpressRouteCircuitSub = $sheet.Cells.Item(9,2).Text 
$global:nameofonpremexrcircuit = $sheet.Cells.Item(10,2).Text 
$global:rgofonpremexrcircuit = $sheet.Cells.Item(11,2).Text 

#Only Use these variables if you are using an EXISTING ExpressRoute Gateway to connect AVS
If($exrgwneworexisting -eq "Existing"){

  $global:exrgwsub = $sheet.Cells.Item(12,2).Text  #This could be the same or different Sub ID than the private cloud.
  $global:exrvnetname = $sheet.Cells.Item(13,2).Text  #The name of the vNet where the expressroute gateway already exists.
  $global:exrgwname = $sheet.Cells.Item(14,2).Text  #The name of the ExpressRoute Gateway
  $global:exrgwrg = $sheet.Cells.Item(15,2).Text  #The resource group of the ExpressRoute Gateway
  $global:exrgwregion = $sheet.Cells.Item(16,2).Text  #the region where the ExpressRoute Gateway is located
  }

#Only Use these variables if there is a need to create a NEW expressroute gateway to connect AVS 
If($exrgwneworexisting -eq "New"){

  $global:exrgwsub = $sheet.Cells.Item(12,2).Text  #This could be the same or different Sub ID than the private cloud.
  $global:exrvnetname = $sheet.Cells.Item(13,2).Text  #The name of the vNet where the expressroute gateway already exists.
  $global:exrgwname = $sheet.Cells.Item(14,2).Text  #The name of the ExpressRoute Gateway
  $global:exrgwrg = $sheet.Cells.Item(15,2).Text  #The resource group of the ExpressRoute Gateway
  $global:exrgwregion = $sheet.Cells.Item(16,2).Text  #the region where the ExpressRoute Gateway is located
  $global:gatewaysubnetaddressspace = $sheet.Cells.Item(17,2).Text #this is the subnet for the GatewaySubnet subnet which is needed for the ExpressRoute Gateway
  }


  $global:numberofhosts = "3" #This should be left at 3
  $global:internet = "Enabled" 
  
$excel.Quit()

Stop-Process -Name EXCEL -Force

#DO NOT MODIFY BELOW THIS LINE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ProgressPreference = 'SilentlyContinue'
#$ErrorActionPreference = 'SilentlyContinue'

#ID Path where this script is running
$global:myjsonpath = $MyInvocation.MyCommand.Path 
$global:myjsonpath = split-path $myjsonpath -Parent
$global:myjsonpath = $myjsonpath+"\config_avs.json"


#Variables Do Not Modify
$testing = 0
$global:nameofavsglobalreachconnection = "to-$nameofonpremexrcircuit"
$global:avsexrauthkeyname = "to-ExpressRouteGateway-$exrgwname"
$global:avsexrgwconnectionname = "from-AVSPrivateCloud-$pcname"
$global:gatewaysubnetname = "GatewaySubnet" #DO NOT MODIFY
$global:exrgwipname = "$exrgwname-PIP" #DO NOT MODIFY
$global:folderforstaging = "AVS-Deployment" #DO NOT MODIFY
$global:logfilename = "avs-deploy"

#Create Staging Directory
$test = Test-Path -Path $env:TEMP\$folderforstaging
    
if ($test -eq "True"){
Write-Host -ForegroundColor Blue "Folder $env:TEMP\$folderforstaging Already Exists"}

else {

mkdir $env:TEMP\$folderforstaging
}

#Start Logging
Start-Transcript -Path $env:TEMP\$folderforstaging\$logfilename".log" -Append

#Execution

Clear-Host
Write-Host -ForegroundColor Magenta "Deploying Private Cloud $pcname
"
$files = `
"01_RegisterAVSResourceProvider.ps1",`
"02_CreateResourceGroup.ps1",`
"03_deployavsprivatecloud.ps1",`
"04_createexpressroutegateway.ps1",`
"05_connectavstoexrgw.ps1",`
"06_ConnectAVStoOnPremExR.ps1",`
"07_deployarcforavs.ps1"

foreach ($filename in $files)
{
  Write-Host "Downloading $filename"
  Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$filename" -OutFile $env:TEMP\$folderforstaging\$filename
}
Write-Host ""

<#
##Register Resource Provider
Write-Host -ForegroundColor Yellow "Registering Resource Provider"
$filename = "01_RegisterAVSResourceProvider.ps1"
. $env:TEMP\$folderforstaging\$filename

#Create Resource Group
Write-Host -ForegroundColor Yellow "Creating Resource Group"
$filename = "02_CreateResourceGroup.ps1"
. $env:TEMP\$folderforstaging\$filename

#Deploy Private Cloud
Write-Host -ForegroundColor Yellow "Deploying Private Cloud"
$filename = "03_deployavsprivatecloud.ps1"
. $env:TEMP\$folderforstaging\$filename 

#Create ExpressRoute Gateway
Write-Host -ForegroundColor Yellow "Creating ExpressRoute Gateway"
$filename = "04_createexpressroutegateway.ps1"
. $env:TEMP\$folderforstaging\$filename 

#Connect AVS to ExR GW
Write-Host -ForegroundColor Yellow "Connect AVS to ExpressRoute Gateway"
$filename = "05_connectavstoexrgw.ps1"
. $env:TEMP\$folderforstaging\$filename 

#Connect AVS to On-Prem ExR
if ($OnPremConnectivity -eq "ExpressRoute") {
  Write-Host -ForegroundColor Yellow "Connecting AVS to On-Prem ExpressRoute"
  $filename = "06_ConnecrtAVStoOnPremExR.ps1"
  . $env:TEMP\$folderforstaging\$filename 
}

#>
#Deploy ARC for AVS
Write-Host -ForegroundColor Yellow "Connect AVS to ExpressRoute Gateway"
$filename = "07_deployarcforavs.ps1"
. $env:TEMP\$folderforstaging\$filename 
