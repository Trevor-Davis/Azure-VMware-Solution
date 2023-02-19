#Check the Pre-Reqs

$powershellversion = $psversiontable.PSVersion.Major

if ( $powershellversion -lt 7)
{
Write-Host -ForegroundColor Red "PowerShell version 7 or above is required, you are running version $powershellversion"
Write-Host  "https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows
"

Exit
}
else {
    Write-Host "Powershell:" -NoNewline
    Write-Host -ForegroundColor Green " OK" 
    }

$azvmwaremodule = Get-Module -ListAvailable -Name Az.VMware
if ($azvmwaremodule.Count -eq 0)
{
    Write-Host -ForegroundColor Red "The Az.VMware Powershell module needs to be installed."
    Write-Host  "https://www.powershellgallery.com/packages/Az.VMWare
    "
    Exit
}
else {
    Write-Host "Az.VMware Module:" -NoNewline
    Write-Host -ForegroundColor Green " OK" 
    }

$azcli = az --version
if ($azcli.Count -eq 0)
{
    Write-Host -ForegroundColor Red "The Az CLI needs to be installed."
    Write-Host  "https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
    "
    Exit
}
else {
Write-Host "Azure CLI:" -NoNewline
Write-Host -ForegroundColor Green " OK" 
}

$excelcheck = New-Object -ComObject Excel.application 
if ($excelcheck.Value -ne "Microsoft Excel")
{
    Write-Host -ForegroundColor Red "
    
    
Excel needs to be installed on this machine"
    
    Exit
}
else {
Write-Host "Excel:" -NoNewline
Write-Host -ForegroundColor Green " OK" 
}

# start Excel
<#
$filename = "\avssimplifieddeployment.xlsm"
#$fullpath = $PSScriptRoot+$filename

$process = Start-Process -FilePath "$fullpath" -PassThru

# Get the process ud
$process.ID

# Wait 1 second
Start-Sleep 5

# Kill the process
Stop-Process -id $process.Id

#>
$filename = "\avssimplifieddeployment.xlsm"
#$fullpath = $PSScriptRoot+$filename
$fullpath = "C:\Users\tredavis\OneDrive - Microsoft\GitHub\Azure VMware Solution\AVS-Deployment\avssimplifieddeployment.xlsm"

$excel = New-Object -comobject Excel.Application
$workbook = $excel.Workbooks.Open($fullpath) 

$excel.Visible = $true
$excel.DisplayFullScreen = $true


Write-Host -ForegroundColor Blue "An Excel file has just opened, navigate to that excel file and complete the AVS Simplified Deployment input form, after saving and closing that Excel file return to this Powershell screen."

Start-Sleep -seconds 10

Write-Host -ForegroundColor Yellow "After completing the AVS Simplifed Deployment input form, saving and closing the file, press any key to continue ...."
Read-Host

<#

do {
    Start-Sleep -Seconds 5
    $workbooknamecount = $workbook.name.Count
} until ($workbooknamecount -ne 1)
Write-Host = "trevor"
Exit

Write-Host -ForegroundColor Yellow "The file $filename has been closed, please wait just a few seconds ... "
Start-Sleep -Seconds 10
#>

#Read in the excel variables

#$filename = $PSScriptRoot+$filename

$sheetName = "Variables"

#create new excel COM object
$excel = New-Object -com Excel.Application

#open excel file
$wb = $excel.workbooks.open($fullpath)

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


$global:deployarc = $sheet.Cells.Item(18,2).Text
If($global:deployarc -eq "Yes")
{
$global:networkCIDRForApplianceVM = $sheet.Cells.Item(19,2).Text
}

$global:numberofhosts = $sheet.Cells.Item(21,2).Text
$global:internet = $sheet.Cells.Item(20,2).Text

$excel.Quit()

#DO NOT MODIFY BELOW THIS LINE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
$ProgressPreference = 'SilentlyContinue'

#Variables Do Not Modify
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

#Confirm Values

$a = @{"AVS Private Cloud Name" = $pcname}
$b = @{"Sub ID for the AVS Private Cloud" = $avssub}
$c = @{"Region to deploy the AVS Private Cloud" = $regionfordeployment}
$d = @{"Resource Group to deploy the AVS Private Cloud" = $avsrgname}
$e = @{"AVS SKU" = $avssku}
$f = @{"Network Block to Use for AVS Deployment"=$avsaddressblock}
$g = @{""=""}
$h = @{"Connect AVS Private Cloud to New or Existing ExpressRoute Gateway"=$exrgwneworexisting}
$i = @{"AVS ExpressRoute Gateway Sub ID"=$exrgwsub}
$j = @{"AVS ExpressRoute Gateway Name"=$exrgwname}
$k = @{"Region Where the ExpressRoute Gateway $($exrgwname) is (or will be) Located"=$exrgwregion}
$l = @{"Resource Group Where the ExpressRoute Gateway $($exrgwname) is (or will be) Located"=$exrgwrg}
if ($exrgwneworexisting -eq "New") {$m = @{"vNet Where the ExpressRoute Gateway $($exrgwname) will be) Located"=$exrvnetname}}
$n = @{""=""}
$o = @{"Azure to On-Prem Connectivity Method"= if($OnPremConnectivity -eq "It dosen't"){"Does Not Exist"}else{$OnPremConnectivity}}
$p = @{"Sub ID of the On-Premisis ExpressRoute"=$OnPremExpressRouteCircuitSub}
$q = @{"Name of the On-Premises ExpressRoute Circuit"=$nameofonpremexrcircuit}
$r = @{"Resource Group where $($nameofonpremexrcircuit) is Deployed"=$rgofonpremexrcircuit}
$s = @{""=""}
$t = @{"Deploy Azure ARC for AVS"=$deployarc}
if ($deployarc -eq "Yes") {$u = @{"Network to create in the AVS Private Cloud for ARC"=$networkCIDRForApplianceVM} }

If ($OnPremConnectivity -eq "It dosen't")
{
  $table1 = $a,$b,$c,$d,$e,$f,$g,$h,$i,$j,$k,$l,$m,$n,$o,$s,$t,$u
}  
else {
$table1 = $a,$b,$c,$d,$e,$f,$g,$h,$i,$j,$k,$l,$m,$n,$o,$p,$q,$r,$s,$t,$u}

$table1 | Format-Table -AutoSize -Wrap:$true 

Write-Host -ForegroundColor Yellow "Please Review These Values For Accuracy"
Write-Host -ForegroundColor Yellow -NoNewline "
Continue (Y/N)  "
$continue = Read-Host
If ($continue -ne "y")
{exit}


#Execution #######################################

Clear-Host
Write-Host -ForegroundColor Magenta "Deploying Private Cloud $pcname
"

#Download the Files

$files = @(
    '01_RegisterAVSResourceProvider.ps1'
    '02_CreateResourceGroup.ps1'
    '03_deployavsprivatecloud.ps1'
    '04_createexpressroutegateway.ps1'
    '05_connectavstoexrgw.ps1'
    '06_ConnectAVStoOnPremExR.ps1'
    '07_deployarcforavs.ps1'
)

  foreach ($file in $files )
{
  Out-File -FilePath $env:TEMP\$folderforstaging\$file -Encoding utf8
  $download = 0
  While ($download.StatusCode -ne 200) {
    $download = Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Deployment/$file"  
  }
  Add-Content -Value $download.Content -Path $env:TEMP\$folderforstaging\$file -Encoding utf8  
}



##Register Resource Provider
Write-Host -ForegroundColor Yellow "

Registering Microsoft.AVS Resource Provider"
$filename = "01_RegisterAVSResourceProvider.ps1"
. $env:TEMP\$folderforstaging\$filename

#Create Resource Group
Write-Host -ForegroundColor Yellow "

Creating Resource Group"
$filename = "02_CreateResourceGroup.ps1"
. $env:TEMP\$folderforstaging\$filename

#Deploy Private Cloud
Write-Host -ForegroundColor Yellow "

Deploying Private Cloud"
$filename = "03_deployavsprivatecloud.ps1"
. $env:TEMP\$folderforstaging\$filename 

#Create ExpressRoute Gateway

if ($exrgwneworexisting -eq "New") {
Write-Host -ForegroundColor Yellow "

Creating ExpressRoute Gateway"
$filename = "04_createexpressroutegateway.ps1"
. $env:TEMP\$folderforstaging\$filename 
}

#Connect AVS to ExR GW
Write-Host -ForegroundColor Yellow "

Connect AVS to ExpressRoute Gateway"
$filename = "05_connectavstoexrgw.ps1"
. $env:TEMP\$folderforstaging\$filename 

#Connect AVS to On-Prem ExR
if ($OnPremConnectivity -eq "ExpressRoute") {
  Write-Host -ForegroundColor Yellow "
  
  Connecting AVS to On-Prem ExpressRoute"
  $filename = "06_ConnecrtAVStoOnPremExR.ps1"
  . $env:TEMP\$folderforstaging\$filename 
}

#Deploy ARC for AVS

If($global:deployarc -eq "Yes")
{
Write-Host -ForegroundColor Yellow "

Deployiong ARC for AVS"
$filename = "07_deployarcforavs.ps1"
. $env:TEMP\$folderforstaging\$filename
}


