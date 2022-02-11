##avspcdeploy-variables.ps1
$sub = "1178f22f-6ce4-45e3-bd92-ba89930be5be"
$regionfordeployment = "southeastasia"
$RGNewOrExisting = "Existing" #RGforAVSNewOrExisting

if("New" -eq $RGNewOrExisting)
{
$rgfordeployment = $rgfordeploymentnew

}
else {
$rgfordeployment = 
}


$rgfordeployment = "VirtualWorkloads-APAC-AzureCloud" #rgfordeployment
##or
$rgfordeploymentnew = "" #rgfordeploymentnew
$pcname = "AVS1-VirtualWorkloads-APAC-AzureCloud"
$skus = "AV36"
$addressblock = "10.1.0.0/22"
$ExrGatewayForAVS = "ExRGW-VirtualWorkloads-APAC-Hub" ##existingvnetgwname

$SameSubAVSAndExRGW = "Yes"
if ("Yes" -eq $SameSubAVSAndExRGW) {
$OnPremExRCircuitSub = $sub
}
else {
    $OnPremExRCircuitSub = 
}



$ExrGWforAVSResourceGroup = "VirtualWorkloads-APAC-Hub"
$NameOfOnPremExRCircuit = "tnt15-cust-p01-australiaeast-er" 
$ExrForAVSRegion = "southeastasia" 
$RGofOnPremExRCircuit = "Prod_AVS_RG"  
$internet = "Enabled"
$numberofhosts = "3"


#############################################################################################################
remove-item $env:TEMP\AVSDeploy\*.*
mkdir $env:TEMP\AVSDeploy
Clear-Host

#######################################################################################
# Check for Installs
#######################################################################################

Write-Host -ForegroundColor Yellow "
Is Azure CLI Installed On This Machine? (Y/N)
"

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
    



#connecttoazure.ps1
write-host -ForegroundColor Yellow "
Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
Connect-AzAccount -Subscription $sub
write-host -ForegroundColor Green "
Azure Login Successful
"
#validatesubready.ps1

Write-Host -ForegroundColor Yellow  "
Validating Subscription Readiness ..." 

$quota = Test-AzVMWareLocationQuotaAvailability -Location $regionfordeployment -SubscriptionId $sub

if ("Enabled" -eq $quota.Enabled)
{

Write-Host -ForegroundColor Green "
Success: Quota is Enabled on Subscription
"    

Register-AzResourceProvider -ProviderNamespace Microsoft.AVS

Write-Host -ForegroundColor Green "
Success: Resource Provider Enabled
"    

Start-Sleep 5
}


Else

{
Write-Host -ForegroundColor Red "
Subscription $sub Does NOT Have Quota for Azure VMware Solution, please visit the following site for guidance on how to get this service enabled for your subscription.

https://docs.microsoft.com/en-us/azure/azure-vmware/enable-azure-vmware-solution"

Exit

}

#DefineResourceGroup.ps1
if ( "Existing" -eq $RGNewOrExisting )
{
    write-host -foregroundcolor Green = "
AVS Private Cloud Resource Group is $rgfordeployment
"
}

if ( "New" -eq $RGNewOrExisting){
    New-AzResourceGroup -Name $rgfordeployment -Location $regionfordeployment

    write-host -foregroundcolor Green = "
Success: AVS Private Cloud Resource Group $rgfordeployment Created
"   

}

#kickoffdeploymentofavsprivatecloud.ps1


Write-Host -ForegroundColor Green "
Success: The Azure VMware Solution Private Cloud Deployment Has Begun
"
Write-Host -ForegroundColor White "
Deployment Status Will Begin To Show Shortly
"
New-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub -NetworkBlock $addressblock -Sku $skus -Location $regionfordeployment -managementclustersize $numberofhosts -Internet $internet -NoWait -AcceptEULA

Write-Host -foregroundcolor Magenta "
The Azure VMware Solution Private Cloud $pcname deployment is underway and will take approximately 4 hours.
"
Write-Host -foregroundcolor Yellow "
The status of the deployment will update every 5 minutes.
"

Start-Sleep -Seconds 300

$provisioningstate = get-azvmwareprivatecloud -Name $pcname -ResourceGroupName $rgfordeployment
$currentprovisioningstate = $provisioningstate.ProvisioningState
$timeStamp = Get-Date -Format "hh:mm"


while ("Succeeded" -ne $currentprovisioningstate)
{
$timeStamp = Get-Date -Format "hh:mm"
"$timestamp - Current Status: $currentprovisioningstate "
Start-Sleep -Seconds 300
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


#ConnectAVSExrToVnet.ps1

$myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment
$peerid = $myprivatecloud.CircuitExpressRouteId
Write-Host -ForegroundColor Yellow "
Generating AVS ExpressRoute Auth Key..."

$exrauthkey = New-AzVMWareAuthorization -Name "Connection-To-$ExrGatewayForAVS" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment 
if ($exrauthkey.ProvisioningState -eq "Succeeded" ) {
    Write-Host -ForegroundColor Green "
AVS ExpressRoute Auth Key Generated"
    }
    if ($exrauthkey.ProvisioningState -ne "Succeeded" ) {
        Write-Host -ForegroundColor Red "
AVS ExpressRoute Auth Key Generation Failed"
        Exit
        }

Write-Host -ForegroundColor Yellow "
Connecting the $pcname Private Cloud to Virtual Network Gateway $ExrGatewayForAVS ... "

$exrgwtouse = Get-AzVirtualNetworkGateway -ResourceGroupName $ExrGWforAVSResourceGroup -Name $ExrGatewayForAVS
New-AzVirtualNetworkGatewayConnection -Name "From--$pcname" -ResourceGroupName $ExrGWforAVSResourceGroup -Location $ExrForAVSRegion -VirtualNetworkGateway1 $exrgwtouse -PeerId $peerid -ConnectionType ExpressRoute -AuthorizationKey $exrauthkey.Key 
 
Write-host -ForegroundColor Green "
Success: $pcname Private Cloud is Now Connected to to Virtual Network Gateway $ExrGatewayForAVS
"

#ConnectAVSExrToOnPremExr.ps1


if ("yes" -eq $internaltest) {

 

    Select-AzSubscription -SubscriptionId $sub
    Write-Host -ForegroundColor Yellow "Building Global Reach connection from $pcname to the on-premises Express Route $NameOfOnPremExRCircuit...
    "
    New-AzVMwareGlobalReachConnection -Name $NameOfOnPremExRCircuit -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -AuthorizationKey "490b170e-1ae8-404d-bafc-333eaa0e6cde" -PeerExpressRouteResourceId "/subscriptions/52d4e37e-0e56-4016-98de-fe023475b435/resourceGroups/tnt15-cust-p01-australiaeast/providers/Microsoft.Network/expressRouteCircuits/tnt15-cust-p01-australiaeast-er"
    
    $provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
    $currentprovisioningstate = $provisioningstate.CircuitConnectionStatus
    
    while ("Connected" -ne $currentprovisioningstate)
    {
    write-Host -ForegroundColor Yellow "Current Status of Global Reach Connection: $currentprovisioningstate"
    Start-Sleep -Seconds 10
    $provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
    $currentprovisioningstate = $provisioningstate.CircuitConnectionStatus}
    
    if("Connected" -eq $currentprovisioningstate)
    {
      Write-Host -ForegroundColor Green "Success: AVS Private Cloud $pcname is Connected via Global Reach to $NameOfOnPremExRCircuit"
    }  
  
  }
   
  else {
  
  
    Select-AzSubscription -SubscriptionId $OnPremExRCircuitSub
  
    $OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
    Add-AzExpressRouteCircuitAuthorization -Name "For-$pcname" -ExpressRouteCircuit $OnPremExRCircuit
    Set-AzExpressRouteCircuit -ExpressRouteCircuit $OnPremExRCircuit
    
    Write-Host -ForegroundColor Green "
    Success: Auth Key Genereated for AVS On Express Route $NameOfOnPremExRCircuit"
    
    $OnPremExRCircuit = Get-AzExpressRouteCircuit -Name $NameOfOnPremExRCircuit -ResourceGroupName $RGofOnPremExRCircuit
    $OnPremCircuitAuthDetails = Get-AzExpressRouteCircuitAuthorization -ExpressRouteCircuit $OnPremExRCircuit | Where-Object {$_.Name -eq "For-$pcname"}
    $OnPremCircuitAuth = $OnPremCircuitAuthDetails.AuthorizationKey
    
    Select-AzSubscription -SubscriptionId $sub
    New-AzVMwareGlobalReachConnection -Name $NameOfOnPremExRCircuit -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -AuthorizationKey $OnPremCircuitAuth -PeerExpressRouteResourceId $OnPremExRCircuit.Id
    
    $provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
    $currentprovisioningstate = $provisioningstate.CircuitConnectionStatus
    
    while ("Connected" -ne $currentprovisioningstate)
    {
    write-Host -Fore "Current Status of Global Reach Connection: $currentprovisioningstate"
    Start-Sleep -Seconds 10
    $provisioningstate = Get-AzVMwareGlobalReachConnection -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment
    $currentprovisioningstate = $provisioningstate.CircuitConnectionStatus}
    
    if("Connected" -eq $currentprovisioningstate)
    {
      Write-Host -ForegroundColor Green "Success: AVS Private Cloud $pcname is Connected via Global Reach to $NameOfOnPremExRCircuit"
      
    }
  
  
  }
  
  #addhcx.ps1
  
write-Host -ForegroundColor Yellow "Deploying VMware HCX to the $pcname Private Cloud ... This will take approximately 45 minutes ... "
az vmware addon hcx create --resource-group "VirtualWorkloads-APAC-AzureCloud" --private-cloud "AVS1-VirtualWorkloads-APAC-AzureCloud" --offer "VMware MaaS Cloud Provider"
write-Host -ForegroundColor Green "Success: VMware HCX has been deployed to $pcname Private Cloud"
