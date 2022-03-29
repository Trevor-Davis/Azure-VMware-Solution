
. 'C:\users\tredavis\OneDrive - Microsoft\GitHub\Azure VMware Solution\AVSSimplifiedDeployment\variables.ps1'
$quickeditsettingatstartofscript = Get-ItemProperty -Path "HKCU:\Console" -Name Quickedit
Set-ItemProperty -Path "HKCU:\Console" -Name Quickedit 0
$quickeditsettingatstartofscript.QuickEdit


Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

Start-Transcript -Path $env:TEMP\AVSDeploy\avsdeploy.log -Append
. $env:TEMP\AVSDeploy\variables.ps1

$pcdeployed = 0
$hcxdeployed = 0
$pcexrdeployed = 0
$pconpremdeployed = 0
$hcxonpremdeployed = 0
$hcxclouddeployed = 0
$exrgwforvpndeployed = 0
$avsexrauthkeydeployed = 0
$onpremexrauthkeydeployed = 0
$rsdeployed = 0
$exrglobalreachdeployed = 0

#######################################################################################
#Testing, DO NOT MODIFY
#######################################################################################
$skiptheprecheck= "No"

#######################################################################################
#FUNCTIONS
#######################################################################################
#checkfilesize function

function checkfilesize {

  param (
      $filename
  )
  ((Get-Item $filename).Length/1gb)
  
  }


#inputbox
function inputbox {
  param (
      $inputrequest
  )
  $boxtitle = "Azure VMware Solution Simplified Deployment"

  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
  
  $form = New-Object System.Windows.Forms.Form
  $form.Text = $boxtitle
  $form.Size = New-Object System.Drawing.Size(500,200)
  $form.StartPosition = 'CenterScreen'
  
  $okButton = New-Object System.Windows.Forms.Button
  $okButton.Location = New-Object System.Drawing.Point(175,120)
  $okButton.Size = New-Object System.Drawing.Size(75,23)
  $okButton.Text = 'Submit'
  $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
  $form.AcceptButton = $okButton
  $form.Controls.Add($okButton)
  
  $cancelButton = New-Object System.Windows.Forms.Button
  $cancelButton.Location = New-Object System.Drawing.Point(250,120)
  $cancelButton.Size = New-Object System.Drawing.Size(75,23)
  $cancelButton.Text = 'Cancel'
  $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
  $form.CancelButton = $cancelButton
  $form.Controls.Add($cancelButton)
  
  $label = New-Object System.Windows.Forms.Label
  $label.Location = New-Object System.Drawing.Point(10,20)
  $label.Size = New-Object System.Drawing.Size(280,20)
  $label.Text = $inputrequest
  $form.Controls.Add($label)
  
  $textBox = New-Object System.Windows.Forms.TextBox
  $textBox.Location = New-Object System.Drawing.Point(10,40)
  $textBox.Size = New-Object System.Drawing.Size(470,20)
  $form.Controls.Add($textBox)
  
  $form.Topmost = $true
  
  $form.Add_Shown({$textBox.Select()})
  $result = $form.ShowDialog()
  
  if ($result -eq [System.Windows.Forms.DialogResult]::OK)
  {
      $x = $textBox.Text
      $x
  }

}

#azure login function
function azurelogin {

  param (
      $subtoconnect
  )
  $sublist = @()
  $sublist = Get-AzSubscription
  $checksub = $sublist -match $subtoconnect
  $getazcontext = Get-AzContext
  If ($checksub.Count -eq 1 -and $getazcontext.Subscription.Id -eq $subtoconnect) {" "}
  if ($checksub.Count -eq 1 -and $getazcontext.Subscription.Id -ne $subtoconnect) {Set-AzContext -SubscriptionId $subtoconnect}
  if ($checksub.Count -eq 0) {Connect-AzAccount -Subscription $subtoconnect}
  }

#vCenter Communication Test

  function checkavsvcentercommunication {

    param (
    
    )
    Write-Host -ForegroundColor Yellow "
Checking communication to AVS Private Cloud ... "
    azurelogin -subtoconnect $sub
    $myprivatecloud = Get-AzVMwarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -Subscription $sub
    $vcenterurl = $myprivatecloud.EndpointVcsa
    $length = $vcenterurl.length 
    $vCenterCloudIP = $vcenterurl.Substring(8,$length-9)
    $check = Test-Connection -IPv4 -TcpPort 443 $vCenterCloudIP
    $check | ConvertTo-Json
    }


#######################################################################################
# Create Temp Storage Location
#######################################################################################
Clear-Host







#############11111111111#############
if ("ExpressRoute" -eq $AzureConnection) {
    $ErrorActionPreference = "SilentlyContinue"; $WarningPreference = "SilentlyContinue"
    azurelogin -subtoconnect $sub
    $ErrorActionPreference = "Continue"; $WarningPreference = "Continue"
      
    $myprivatecloud = Get-AzVMWarePrivateCloud -Name $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub
    $peerid = $myprivatecloud.CircuitExpressRouteId
    
    $ErrorActionPreference = "SilentlyContinue"; $WarningPreference = "SilentlyContinue"
    azurelogin -subtoconnect $vnetgwsub
    
    $status = get-AzVMWareAuthorization -Name "to-ExpressRouteGateway" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $vnetgwsub -ErrorAction "SilentlyContinue"
    #############2222222222#############
    if ($status.count -eq 1) {
      $avsexrauthkeydeployed = 1
      write-Host -ForegroundColor Blue "
    ExpressRoute Authorization Key Already Generated, Skipping To Next Step..."
    }
    #############2222222222#############
    $ErrorActionPreference = "Continue"; $WarningPreference = "Continue"
    
    #############3333333333#############
    if ($avsexrauthkeydeployed -eq 0) {
      
    Write-Host -ForegroundColor Yellow "
    Generating AVS ExpressRoute Auth Key..."
    
    $ErrorActionPreference = "SilentlyContinue"; $WarningPreference = "SilentlyContinue"
    azurelogin -subtoconnect $sub
    $ErrorActionPreference = "Continue"; $WarningPreference = "Continue"
    
    $exrauthkey = New-AzVMWareAuthorization -Name "to-ExpressRouteGateway" -PrivateCloudName $pcname -ResourceGroupName $rgfordeployment -SubscriptionId $sub
    if ($exrauthkey.ProvisioningState -ne "Succeeded"){Write-Host -ForegroundColor Red "Creation of the AVS ExpressRoute Auth Key Failed"
    Exit}
        Write-Host -ForegroundColor Green "
    AVS ExpressRoute Auth Key Generated"
    }
    #############3333333333#############
}
    
    
    
    
    $ErrorActionPreference = "SilentlyContinue"; $WarningPreference = "SilentlyContinue"
azurelogin -subtoconnect $vnetgwsub



$x = $virtualHub.ExpressRouteGateway.Id
$ExrGatewayForAVS = $x.split("/",9)[-1]
$vwanexrgw = Get-AzExpressRouteGateway -ResourceGroupName $ExrGWforAVSResourceGroup -Name $ExrGatewayForAVS 
$command = New-AzExpressRouteConnection -ResourceGroupName "Prod_AVS_RG" -ParentResourceName "8c586e8018e14f5783d7a4111f0b8b76-westus-er-gw" -Name "From--$pcname" -ExpressRouteCircuitPeeringId $peerid -AuthorizationKey $exrauthkey.Key -ParentResourceName $virtualHub.Name
$command


New-AzExpressRouteConnection -ResourceGroupName $ExrGatewayForAVS.ResourceGroupName -ParentResourceName $ExrGatewayForAVS.Name -Name "testConnection" -ExpressRouteCircuitPeeringId "/subscriptions/1543a39a-4e61-4ef2-9d4e-3a8d8a97cd54/resourceGroups/tnt79-cust-p01-westus/providers/Microsoft.Network/expressRouteCircuits/tnt79-cust-p01-westus-er" -AuthorizationKey "7b3aa92c-396e-4ec4-89ec-0dfa17d0a4c0"
-RoutingWeight 20

$command | ConvertTo-Json

Get-AzExpressRouteConnection -ResourceGroupName $ExrGWforAVSResourceGroup -ExpressRouteGatewayName $ExrGatewayForAVS 


#$virtualWan = get-AzVirtualWan -ResourceGroupName "VirtualWorkloads" -Name "VirtualWorkloads-vWAN" 
#$virtualHub = New-AzVirtualHub -VirtualWan $virtualWan -ResourceGroupName "VirtualWorkloads" -Name "VirtualWorkloads-vWANHub" -AddressPrefix "192.168.254.0/24" -Location "West US"

$virtualHub = Get-AzVirtualHub -Name $VWanHUBNameWithExRGW -ResourceGroupName $ExrGWforAVSResourceGroup
$x = $virtualHub.ExpressRouteGateway.Id
$ExrGatewayForAVS = $x.split("/",9)[-1]

#New-AzExpressRouteGateway -ResourceGroupName $ExrGWforAVSResourceGroup -Name "VirtualWorkloads-vWAN-ExRGW" -VirtualHubId $virtualHub.Id -MinScaleUnits 2

$ExpressRouteGateway = Get-AzExpressRouteGateway -ResourceGroupName $ExrGWforAVSResourceGroup -Name $ExrGatewayForAVS
New-AzExpressRouteConnection -ExpressRouteGatewayName $ExpressRouteGateway.Name -ResourceGroupName $ExpressRouteGateway.ResourceGroupName -Name "testConnection" -ExpressRouteCircuitPeeringId "/subscriptions/1543a39a-4e61-4ef2-9d4e-3a8d8a97cd54/resourceGroups/tnt79-cust-p01-westus/providers/Microsoft.Network/expressRouteCircuits/tnt79-cust-p01-westus-er" -AuthorizationKey "7b3aa92c-396e-4ec4-89ec-0dfa17d0a4c0"
Get-AzExpressRouteCircuit -ResourceGroupName "VirtualWorkloads-AVS" -Name "/subscriptions/1543a39a-4e61-4ef2-9d4e-3a8d8a97cd54/resourceGroups/tnt79-cust-p01-westus/providers/Microsoft.Network/expressRouteCircuits/tnt79-cust-p01-westus-er"
#PS C:\> $ExpressRouteCircuit = New-AzExpressRouteCircuit -ResourceGroupName "testRG" -Name "testExpressRouteCircuit" -Location "West Central US" -SkuTier Premium -SkuFamily MeteredData -ServiceProviderName "Equinix" -PeeringLocation "Silicon Valley" -BandwidthInMbps 200
#PS C:\> Add-AzExpressRouteCircuitPeeringConfig -Name "AzurePrivatePeering" -ExpressRouteCircuit $ExpressRouteCircuit -PeeringType AzurePrivatePeering -PeerASN 100 -PrimaryPeerAddressPrefix "123.0.0.0/30" -SecondaryPeerAddressPrefix "123.0.0.4/30" -VlanId 300
#PS C:\> $ExpressRouteCircuit = Set-AzExpressRouteCircuit -ExpressRouteCircuit $ExpressRouteCircuit
#PS C:\> $ExpressRouteCircuitPeeringId = $ExpressRouteCircuit.Peerings[0].Id
