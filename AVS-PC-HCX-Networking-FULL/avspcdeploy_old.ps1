# Author: Trevor Davis
# Twitter: @vTrevorDavis
# Powershell 7 Is Required

#########################


########## Browse for User Input File ##########
$spreadsheetdone = Read-Host -Prompt "
Have you populated the spreadsheet avsinputs.xlsm, and is that file saved to the same system you are running this script on? (Y/N)"

if ("y" -eq $spreadsheetdone) {
Write-Host -NoNewLine "
You will now be asked to locate the file avsinputs.xlsm on your local system.  Press any key to continue ...";
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

   Add-Type -AssemblyName System.Windows.Forms
   $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
   [void]$FileBrowser.ShowDialog()
   $file = $FileBrowser.FileName
   $sheetName = "userinputs"
}

elseif ("n" -eq $spreadsheetdone) {
   {write-host -ForegroundColor Red "Please populate the spreadsheet avsinputs.xlsm before deploying Azure VMware Solution"
   Exit}
}


########## Create an instance of Excel.Application and Open Excel file ########## 
$objExcel = New-Object -ComObject Excel.Application
$workbook = $objExcel.Workbooks.Open($file)
$sheet = $workbook.Worksheets.Item($sheetName)
$objExcel.Visible=$false
#Count max row
$rowMax = ($sheet.UsedRange.Rows).count
#Declare the starting positions
$rowsub,$colsub = 1,1
$rowrgnewold,$colrgnewold = 1,2
$rowrgfordeployment,$colrgfordeployment = 1,3
$rowregionfordeployment,$colregionfordeployment = 1,4
$rowpcname,$colpcname = 1,5
$rowvnetandexr,$colvnetandexr = 1,6
$rowvnetname,$colvnetname = 1,7
$rowvnetaddressprefix,$colvnetaddressprefix = 1,8
$rowdefaultsubnetprefix,$coldefaultsubnetprefix = 1,9
$rowgwsubnetprefix,$colgwsubnetprefix = 1,10
$rowinternet,$colinternet = 1,11
$rowaddressblock,$coladdressblock = 1,12
$rowskus,$colskus = 1,13
$rownumberofhosts,$colnumberofhosts = 1,14

#loop to get values and store it ####################
for ($i=1; $i -le $rowMax-1; $i++)
{
$sub = $sheet.Cells.Item($rowsub+$i,$colsub).text
$rgnew = $sheet.Cells.Item($rowrgnewold+$i,$colrgnewold).text
$rgfordeployment = $sheet.Cells.Item($rowrgfordeployment+$i,$colrgfordeployment).text
$regionfordeployment = $sheet.Cells.Item($rowregionfordeployment+$i,$colregionfordeployment).text
$pcname = $sheet.Cells.Item($rowpcname+$i,$colpcname).text
$vnetandexr = $sheet.Cells.Item($rowvnetandexr+$i,$colvnetandexr).text
$vnetname = $sheet.Cells.Item($rowvnetname+$i,$colvnetname).text
$vnetaddressprefix = $sheet.Cells.Item($rowvnetaddressprefix+$i,$colvnetaddressprefix).text
$defaultsubnetprefix = $sheet.Cells.Item($rowdefaultsubnetprefix+$i,$coldefaultsubnetprefix).text
$gwsubnetprefix = $sheet.Cells.Item($rowgwsubnetprefix+$i,$colgwsubnetprefix).text
$internet = $sheet.Cells.Item($rowinternet+$i,$colinternet).text
$addressblock = $sheet.Cells.Item($rowaddressblock+$i,$coladdressblock).text
$skus = $sheet.Cells.Item($rowskus+$i,$colskus).text
$numberofhosts = $sheet.Cells.Item($rownumberofhosts+$i,$colnumberofhosts).text



<#Write-Host ("Subscription: "+$sub)
Write-Host ("Create New or Use Existing Resource Group: "+$rgnewold)
Write-Host ("Resource Group: "+$rgfordeployment)
Write-Host ("Region: "+$regionfordeployment)
write-Host ("Private Cloud Name:"+$pcname)
write-Host ("vNet and ExR Combo:"+$vnetandexr)
Write-Host ("New vNet Name: "+$vnetname)
Write-Host ("vNet Address Prefix: "+$vnetaddressprefix)
Write-Host ("Default Subnet Prefix: "+$defaultsubnetprefix)
Write-Host ("Gateway Subnet Prefix: "+$gwsubnetprefix)
Write-Host ("Internet: "+$internet)
write-host ("Address Block: "+$addressblock)
write-host ("SKU: "+$skus)
write-host ("Number of Hosts: "+$numberofhosts)

#>
}
#close excel file ####################
$objExcel.quit()
##################################################################################

$gwname = "$pcname-ExRGW"
$gwipName = "$gwname-IP"
$gwipconfName = "$gwname-ipconf"
$gatewaysubnetname = "GatewaySubnet"
$defaultsubnetname = "default"

########## Connect To Azure  #######################################


write-host -ForegroundColor Green "

Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
Connect-AzAccount -Subscription $sub

#######################################
# Validate Subscription Readiness for AVS
#######################################


Write-Host -ForegroundColor Yellow  "
Validating Subscription Readiness ...please wait" 

$quota = Test-AzVMWareLocationQuotaAvailability -Location $regionfordeployment

if ("Enabled" -eq $quota.Enabled)
{

Write-Host -ForegroundColor Yellow  "
Enabling Azure VMware Solution Resource Provider
"

   Register-AzResourceProvider -ProviderNamespace Microsoft.AVS

Write-Host -ForegroundColor Green  "
Subscription $sub has been validated, Azure VMware Solution is ENABLED ... please wait
"
Start-Sleep 1
}

#}


Else
{
Write-Host -ForegroundColor Red "
Subscription $sub is NOT ENABLED for Azure VMware Solution, please visit the following site for guidance on how to get this service enabled for your subscription.

https://docs.microsoft.com/en-us/azure/azure-vmware/enable-azure-vmware-solution"

Exit

}


#######################################
# Define Resource Group
#######################################

if ( "existing" -eq $rgnew )
{
write-host -foregroundcolor blue = "================================="
$RGs = Get-AzResourceGroup
$Count = 0

 foreach ($rg in $RGs) {
    $RGname = $rg.ResourceGroupName
    Write-Host "$Count - $RGname"
    $Count++
 }

write-host -foregroundcolor blue = "================================="
$rgselection = Read-Host -Prompt "
Select the number from the list above which corresponds to the Resource Group where the Azure VMware Solution Private Cloud will be deployed"
$rgtouse = $RGs["$rgselection"].ResourceGroupName
$rgfordeployment = $rgtouse

}
else
{

Write-Host -ForegroundColor Yellow "Creating Azure Resource Group ... "
New-AzResourceGroup -Name $rgfordeployment -Location $regionfordeployment

}

#######################################
# Define vCenter Password
#######################################
$passwordsuccess = 0
while($passwordsuccess -eq 0)
{
$vcenterpassword1 = Read-Host -Prompt "
Provide a password that will be used for Azure VMware Solution Private Cloud vCenter Server access" -MaskInput 
$vcenterpassword2 = Read-Host -Prompt "
Re-Enter the vCenter password" -MaskInput

if ($vcenterpassword1 -eq $vcenterpassword2) 
{
$vcenterpassword = $vcenterpassword1
$passwordsuccess = 1

}
else
{Write-Host -foregroundcolor Red "
The Passwords Do Not Match
"}
}

#######################################
# Define NSX Password
#######################################

$passwordsuccess = 0
while($passwordsuccess -eq 0)
{
$nsxpassword1 = Read-Host -Prompt "
Provide a password that will be used for Azure VMware Solution Private Cloud NSX-T Manager access" -MaskInput
$nsxpassword2 = Read-Host -Prompt "
Re-Enter the NSX-T password" -MaskInput

if ($nsxpassword1 -eq $nsxpassword2) 
{
$nsxpassword = $nsxpassword1
$passwordsuccess = 1

}
else
{Write-Host ""
"The Passwords Do Not Match
"}
}

########## Option 2 Use an existing Azure Virtual Network and Create an ExpressRoute Gateway ##################

if ("2" -eq $vnetandexr) {

  # Define vNet  #######################################
  
  write-host -foregroundcolor blue = "================================="
  $VNETs = Get-AzVirtualNetwork
  $Count = 0
  
  foreach ($vnet in $VNETs) {
     $VNETname = $vnet.Name
     Write-Host "$Count - $VNETname"
     $Count++
  }
  
  write-host -foregroundcolor blue = "
  ================================="
  $vnetselection = Read-Host -Prompt "
  Select the number which corresponds to the Virtual Network where the Virtual Network Gateway for the Azure VMware Solution Private Cloud Express Route will be deployed"
  $vnettouse = $VNETs["$vnetselection"].Name
}
########## Option 3 Use an existing ExpressRoute Gateway ################

if ("3" -eq $vnetandexr) {

  # Pick the ExR Gateway to use ###############################
  
  write-host -foregroundcolor blue = "================================="
  $exrgws = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment
      $Count = 0
      
       foreach ($exrgw in $exrgws) {
          $exrgwlist = $exrgw.Name
          Write-Host "$Count - $exrgwlist"
          $Count++
       }
       
      
       write-host -foregroundcolor blue = "
       ================================="
       $exrgwselection = Read-Host -Prompt "
  Select the number which corresponds to the ExpressRoute Gateway which will be use to connect your Azure VMware Solution ExpressRoute to"
      $exrgwtouse = $exrgws["$exrgwselection"].Name

      }
 
#######################################
# Confirm Deployment Values
#######################################

Write-Host -ForegroundColor Yellow "
---- Confirm The Following Is Accurate ---- 
"
    Write-Host -NoNewline -ForegroundColor Green "Subscription: "
    Write-Host -ForegroundColor White $sub

    if ("create new" -eq $rgnew){
      Write-Host -NoNewline -ForegroundColor Green "Resource Group To Be Created: "
      Write-Host -ForegroundColor White $rgfordeployment
    }
    
    if ("existing" -eq $rgnew){
      Write-Host -NoNewline -ForegroundColor Green "Resource Group To Be Used: "
      Write-Host -ForegroundColor White $rgfordeployment
    }

    Write-Host -NoNewline -ForegroundColor Green "Location: "
    Write-Host -ForegroundColor White $regionfordeployment

    Write-Host -NoNewline -ForegroundColor Green "Private Cloud Name: "
    Write-Host -ForegroundColor White $pcname
    
    Write-Host -NoNewline -ForegroundColor Green "SKU: "
    Write-Host -ForegroundColor White $skus

    Write-Host -NoNewline -ForegroundColor Green "Hosts: "
    Write-Host -ForegroundColor White $numberofhosts "(Additional Hosts can be added after initial deployment as needed)."

    Write-Host -NoNewline -ForegroundColor Green "vCenter Password: "
    Write-Host -ForegroundColor White "*****************************" 

    Write-Host -NoNewline -ForegroundColor Green "NSX Password: "
    Write-Host -ForegroundColor White "*****************************" 

    Write-Host -NoNewline -ForegroundColor Green "Private Cloud Address Block: "
    Write-Host -ForegroundColor White $addressblock

    Write-Host -NoNewline -ForegroundColor Green "Internet Enabled/Disabled: "
    Write-Host -ForegroundColor White $internet

    if ("1" -eq $vnetandexr){
      Write-Host -NoNewline -ForegroundColor Green "Virtual Network To Be Created: "
      Write-Host -ForegroundColor White $vnetname

      Write-Host -NoNewline -ForegroundColor Green "Virtual Network $vnetname Address Prefix: "
      Write-Host -ForegroundColor White $vnetaddressprefix

      Write-Host -NoNewline -ForegroundColor Green "Virtual Network default subnet Address Prefix: "
      Write-Host -ForegroundColor White $defaultsubnetprefix

      Write-Host -NoNewline -ForegroundColor Green "Virtual Network GatewaySubnet Address Prefix: "
      Write-Host -ForegroundColor White $gwsubnetprefix

      Write-Host -NoNewline -ForegroundColor Green "ExpressRoute Gateway To Be Created: "
      Write-Host -ForegroundColor White $gwname
    }

    if ("2" -eq $vnetandexr){
      Write-Host -NoNewline -ForegroundColor Green "Virtual Network To Be Used: "
      Write-Host -ForegroundColor White $vnetname

      Write-Host -NoNewline -ForegroundColor Green "Virtual Network GatewaySubnet Address Prefix: "
      Write-Host -ForegroundColor White $gwsubnetprefix

      Write-Host -NoNewline -ForegroundColor Green "ExpressRoute Gateway To Be Created: "
      Write-Host -ForegroundColor White $gwname
    }

    if ("3" -eq $vnetandexr){

      Write-Host -NoNewline -ForegroundColor Green "ExpressRoute Gateway To Be Used: "
      Write-Host -ForegroundColor White $gwname
    }

    
#######################################
# Deployment of AVS Private Cloud
#######################################
 
$begindeployment = Read-Host -Prompt "
Would you like to begin the Azure VMware Solution deployment (Y/N)"

if ("y" -eq $begindeployment)
{
   
Write-Host -Foregroundcolor Red " 
The script will pause for up to 5 minutes ... please wait
"

$deploymentkickofftime = get-date -format "hh:mm"

# New-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub -NetworkBlock $addressblock -Sku $skus -Location $regionfordeployment -NsxtPassword $nsxpassword -VcenterPassword $vcenterpassword -managementclustersize $numberofhosts -Internet $internet -NoWait
}
else
{
    Write-Host -Foregroundcolor Red " 
    The script was terminated
    "
    Exit
 }


#######################################
# Checking Deployment Status
#######################################

$provisioningstate = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"

Write-Host -foregroundcolor Magenta "
The Azure VMware Solution Private Cloud $pcname deployment is underway and will take approximately 3 hours, the status of the deployment will update every 10 minutes.

The start time of the deployment was $deploymentkickofftime
"

while ("Succeeded" -ne $currentprovisioningstate)
{
$timeStamp = Get-Date -Format "hh:mm"
"$timestamp - Current Status: $currentprovisioningstate "
Start-Sleep -Seconds 600
$provisioningstate = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
}

if("Succeeded" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Green "$timestamp - Azure VMware Solution Private Cloud $pcname is successfully deployed"
  
}

if("Failed" -eq $currentprovisioningstate)
{
  Write-Host -ForegroundColor Red "$timestamp - Current Status: $currentprovisioningstate

  There appears to be a problem with the deployment of Azure VMware Solution Private Cloud $pcname in subscription $sub "

  Exit

}

####################################################################################
# This is where the networking kicks off assuming the pc was deployed successfully
####################################################################################
else
{


########## Option 1 Create a New Azure Virtual Network and ExpressRoute Gateway #################################

if ("1" -eq $vnetandexr) {

  # CREATES THE VNET AND DEFAULT SUBNET  ################################
   
  New-AzVirtualNetwork -ResourceGroupName $rgfordeployment -Location $regionfordeployment -Name $vnetname -AddressPrefix $vnetaddressprefix 
  New-AzVirtualNetworkSubnetConfig -Name $defaultsubnetname -AddressPrefix $defaultsubnetprefix
  $avsvnet = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rgfordeployment
  Add-AzVirtualNetworkSubnetConfig -Name $defaultsubnetname -VirtualNetwork $avsvnet -AddressPrefix $defaultsubnetprefix
  $avsvnet | Set-AzVirtualNetwork
  
  # $avsgatewaysubnetconfig = New-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -AddressPrefix $gwsubnetprefix
  # $avsgatewaysubnet = Add-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $avsvnet -AddressPrefix $gwsubnetprefix
  
  # CREATES THE GATEWAY SUBNET AND EXR GATEWAY ################################
   
  $vnet = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rgfordeployment
  Add-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $vnet -AddressPrefix $gwsubnetprefix
  $vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet
  $subnet = Get-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $vnet
  $pip = New-AzPublicIpAddress -Name $gwipName  -ResourceGroupName $rgfordeployment -Location $regionfordeployment -AllocationMethod Dynamic
  $ipconf = New-AzVirtualNetworkGatewayIpConfig -Name $gwipconfName -Subnet $subnet -PublicIpAddress $pip
  $deploymentkickofftime = get-date -format "hh:mm"
  
  New-AzVirtualNetworkGateway -Name $gwname -ResourceGroupName $rgfordeployment -Location $regionfordeployment -IpConfigurations $ipconf -GatewayType Expressroute -GatewaySku Standard -AsJob


   Write-Host -foregroundcolor Magenta "
   The Virtal Network Gateway $gwname deployment is underway and will take approximately 30 minutes
   
   The start time of the deployment was $deploymentkickofftime
   
   The status of the deployment will update every 2 minutes ... please wait ... 
   "
   
   Start-Sleep -Seconds 120
   
   # Checks Deployment Status ################################
   
   # $provisioningstate = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment
   # $currentprovisioningstate = $provisioningstate.ProvisioningState
   $currentprovisioningstate = "Started"
   $timeStamp = Get-Date -Format "hh:mm"
   
   while ("Succeeded" -ne $currentprovisioningstate)
   {
      $timeStamp = Get-Date -Format "hh:mm"
      "$timestamp - Current Status: $currentprovisioningstate "
      Start-Sleep -Seconds 120
      $provisioningstate = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment
      $currentprovisioningstate = $provisioningstate.ProvisioningState
   } 
   
   if ("Succeeded" -eq $currentprovisioningstate)
   {
   Write-host -ForegroundColor Green "$timestamp - Current Status: $currentprovisioningstate"
   
   $exrgwtouse = $gwname

# Connects AVS to vNet ExR GW ################################

$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment
$peerid = $myprivatecloud.CircuitExpressRouteId
$pcname = $myprivatecloud.name 
Write-Host -foregroundcolor yellow = "
Please Wait ... Generating Authorization Key"
$exrauthkey = New-AzVMWareAuthorization -Name "$pcname-authkey" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment 
$exrgwtouse = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment -Name $exrgwtouse
Write-Host -foregroundcolor yellow "
Please Wait ... Connecting Azure VMware Solution Private Cloud $pcname to Azure Virtual Network Gateway "$exrgwtouse.name" ... this may take a few minutes."
New-AzVirtualNetworkGatewayConnection -Name "$pcname-AVS-ExR-Connection" -ResourceGroupName $rgfordeployment -Location $regionfordeployment -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key
 
# Checks Deployment Status ################################

$provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"

while ("Succeeded" -ne $currentprovisioningstate)
{
  $timeStamp = Get-Date -Format "hh:mm"
  "$timestamp - Current Status: $currentprovisioningstate "
  Start-Sleep -Seconds 20
  $provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
  $currentprovisioningstate = $provisioningstate.ProvisioningState
} 

if ("Succeeded" -eq $currentprovisioningstate)
{
Write-host -ForegroundColor Green "
The Azure VMware Solution Private Cloud has been connected to ExpressRoute Gateway $gwname"

}
   
   }
}
########## Option 2 Use an existing Azure Virtual Network and Create an ExpressRoute Gateway ##################

if ("2" -eq $vnetandexr) {

# CREATES THE GATEWAY SUBNET AND EXR GATEWAY ################################

$vnet = Get-AzVirtualNetwork -Name $vnettouse -ResourceGroupName $rgfordeployment
Add-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $vnet -AddressPrefix $gwsubnetprefix
$vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $gatewaysubnetname -VirtualNetwork $vnet
$pip = New-AzPublicIpAddress -Name $gwipName -ResourceGroupName $rgfordeployment -Location $regionfordeployment -AllocationMethod Dynamic
$ipconf = New-AzVirtualNetworkGatewayIpConfig -Name $gwipconfName -Subnet $subnet -PublicIpAddress $pip
$deploymentkickofftime = get-date -format "hh:mm"

New-AzVirtualNetworkGateway -Name $gwname -ResourceGroupName $rgfordeployment -Location $regionfordeployment -IpConfigurations $ipconf -GatewayType Expressroute -GatewaySku Standard -AsJob


Write-Host -foregroundcolor Magenta "
The Virtal Network Gateway $gwname deployment is underway and will take approximately 30 minutes

The start time of the deployment was $deploymentkickofftime

The status of the deployment will update every 2 minutes ... please wait ... 
"

Start-Sleep -Seconds 120

# Checks Deployment Status ################################

$provisioningstate = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"

while ("Succeeded" -ne $currentprovisioningstate)
{
  $timeStamp = Get-Date -Format "hh:mm"
  "$timestamp - Current Status: $currentprovisioningstate "
  Start-Sleep -Seconds 120
  $provisioningstate = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment
  $currentprovisioningstate = $provisioningstate.ProvisioningState
} 

if ("Succeeded" -eq $currentprovisioningstate)
{
Write-host -ForegroundColor Green "$timestamp - Current Status: $currentprovisioningstate"


$exrgwtouse = $gwname

# Connects AVS to vNet ExR GW ################################

$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment
$peerid = $myprivatecloud.CircuitExpressRouteId
$pcname = $myprivatecloud.name 
Write-Host = "
Please Wait ... Generating Authorization Key"
$exrauthkey = New-AzVMWareAuthorization -Name "$pcname-authkey" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment 
$exrgwtouse = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment -Name $exrgwtouse
Write-Host = "
Please Wait ... Connecting Azure VMware Solution Private Cloud $pcname to Azure Virtual Network Gateway "$exrgwtouse.name" ... this may take a few minutes."
New-AzVirtualNetworkGatewayConnection -Name "$pcname-AVS-ExR-Connection" -ResourceGroupName $rgfordeployment -Location $regionfordeployment -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key
 
# Checks Deployment Status ################################

$provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"

while ("Succeeded" -ne $currentprovisioningstate)
{
  $timeStamp = Get-Date -Format "hh:mm"
  "$timestamp - Current Status: $currentprovisioningstate "
  Start-Sleep -Seconds 20
  $provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
  $currentprovisioningstate = $provisioningstate.ProvisioningState
} 

if ("Succeeded" -eq $currentprovisioningstate)
{
  Write-host -ForegroundColor Green "
The Azure VMware Solution Private Cloud has been connected to ExpressRoute Gateway $gwname"

}
}
}

########## Option 3 Use an existing ExpressRoute Gateway ################

    if ("3" -eq $vnetandexr) {

# Connects AVS to vNet ExR GW ################################

$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment
$peerid = $myprivatecloud.CircuitExpressRouteId
$pcname = $myprivatecloud.name 
Write-Host = "
Please Wait ... Generating Authorization Key"
$exrauthkey = New-AzVMWareAuthorization -Name "$pcname-authkey" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment 
$exrgwtouse = Get-AzVirtualNetworkGateway -ResourceGroupName $rgfordeployment -Name $exrgwtouse
Write-Host = "
Please Wait ... Connecting Azure VMware Solution Private Cloud $pcname to Azure Virtual Network Gateway "$exrgwtouse.name" ... this may take a few minutes."
New-AzVirtualNetworkGatewayConnection -Name "$pcname-AVS-ExR-Connection" -ResourceGroupName $rgfordeployment -Location $regionfordeployment -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key
 
# Checks Deployment Status ################################

$provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"

while ("Succeeded" -ne $currentprovisioningstate)
{
  $timeStamp = Get-Date -Format "hh:mm"
  "$timestamp - Current Status: $currentprovisioningstate "
  Start-Sleep -Seconds 20
  $provisioningstate = Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $rgfordeployment
  $currentprovisioningstate = $provisioningstate.ProvisioningState
} 

if ("Succeeded" -eq $currentprovisioningstate)
{
Write-host -ForegroundColor Green "
Success"

}
    }
  }

$mypcinfo = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $mypcinfo.ProvisioningState
$vcenterurl = $mypcinfo.EndpointVcsa
$nsxturl = $mypcinfo.EndpointNsxtManager
$hcxmanagerurl = $mypcinfo.EndpointHcxCloudManager
$pcname = $mypcinfo.Name
$pclocation = $mypcinfo.Location
$pcinternet = $mypcinfo.Internet
$pcclustersize = $mypcinfo.ManagementClusterSize
$pcsku = $mypcinfo.SkuName

Write-host -ForegroundColor Green "
The Azure VMware Solution Private Cloud $pcname has been successfully deployed."
write-host "=======================================================================
"
Write-Host -NoNewline -ForegroundColor Green "Private Cloud Name: "
Write-Host -ForegroundColor White $pcname
Write-Host -NoNewline -ForegroundColor Green "Azure Region: "
Write-Host -ForegroundColor White $pclocation
Write-Host -NoNewline -ForegroundColor Green "Azure Resource Group: "
Write-Host -ForegroundColor White $rgfordeployment
Write-Host -NoNewline -ForegroundColor Green "Azure Virtual Network AVS ExpressRoute Connects To: "
Write-Host -ForegroundColor White $vnetname
Write-Host -NoNewline -ForegroundColor Green "Azure ExpressRoute Gateway AVS Connects To: "
Write-Host -ForegroundColor White $gwname
Write-Host -NoNewline -ForegroundColor Green "Private Cloud Cluster Size: "
Write-Host -ForegroundColor White $pcclustersize
Write-Host -NoNewline -ForegroundColor Green "Private Cloud Cluster SKU: "
Write-Host -ForegroundColor White $pcsku
Write-Host -NoNewline -ForegroundColor Green "Internet Access From Azure VMware Solution Private Cloud VMs: "
Write-Host -ForegroundColor White $pcinternet 
write-host ""
Write-Host -NoNewline -ForegroundColor Green "vCenter IP URL: "
Write-Host -ForegroundColor White $vcenterurl
Write-Host -NoNewline -ForegroundColor Green "Username: "
Write-Host -ForegroundColor White "cloudadmin@vsphere.local"
Write-Host -NoNewline -ForegroundColor Green "Password: "
Write-Host -ForegroundColor White "The password defined prior to deployement
"
Write-Host -NoNewline -ForegroundColor Green "NSX-T Manager URL: "
Write-Host -ForegroundColor White $nsxturl
Write-Host -NoNewline -ForegroundColor Green "Username: "
Write-Host -ForegroundColor White "admin"
Write-Host -NoNewline -ForegroundColor Green "Password: "
Write-Host -ForegroundColor White "The password defined prior to deployement
"
Write-Host -NoNewline -ForegroundColor Green "HCX Cloud Manager URL: "
Write-Host -ForegroundColor White $hcxmanagerurl
Write-Host -NoNewline -ForegroundColor Green "Username: "
Write-Host -ForegroundColor White "cloudadmin@vsphere.local"
Write-Host -NoNewline -ForegroundColor Green "Password: "
Write-Host -ForegroundColor White "The same password as the vCenter password defined prior to deployment
"

write-host -foregroundcolor Green = "================================="
Write-Host -ForegroundColor Blue "At this point from a virtual machine in the Virtual Network $vnetname you should be able to reach the above URLs for vCenter, HCX Manager and NSX Manager.
"
write-host -foregroundcolor Green = "================================="
