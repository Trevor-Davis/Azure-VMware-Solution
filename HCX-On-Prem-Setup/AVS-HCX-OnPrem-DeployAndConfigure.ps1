# Written By: Trevor Davis
# www.virtualworkloads.com
# @vTrevorDavis


<###stop###
#######################################################################################
# Confirm Requirements Are Met
#######################################################################################


$msg1 = "This script will DEPLOY and CONFIGURE the HCX Connector" 
$msg2 = "ON-PREMISES which will then connect to the AVS private cloud"
$msg3 = "HCX Manager."
$msg4 = ""
$msg5 = "FOR THIS SCRIPT TO FUNCTION THE FOLLOWING IS REQUIRED ON"
$msg6 = "THE LOCAL WINDOWS MACHINE:"
$msg7 = "- Powershell 7.x"
$msg8 = "- VMware PowerCLI"
$msg9 = "- HCX Powershell Module"
$msg10 = "- HCX Connector OVA file"

$msg1yposition = "20"
$msg3yposition = "40"
$msg4yposition = "60"
$msg5yposition = "80"
$msg6yposition = "100"
$msg7yposition = "120"
$msg8yposition = "140"
$msg9yposition = "160"
$msg10yposition = "180"


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'AVS HCX On-Prem Deploy and Config'
$form.Size = New-Object System.Drawing.Size(400,350)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(125,250)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'Continue'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(200,250)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,$msg1yposition)
$label1.Size = New-Object System.Drawing.Size(400,20)
$label1.Text = $msg1
$form.Controls.Add($label1)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,$msg2yposition)
$label2.Size = New-Object System.Drawing.Size(400,20)
$label2.Text = $msg2
$form.Controls.Add($label2)

$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(10,$msg3yposition)
$label3.Size = New-Object System.Drawing.Size(400,20)
$label3.Text = $msg3
$form.Controls.Add($label3)

$label4 = New-Object System.Windows.Forms.Label
$label4.Location = New-Object System.Drawing.Point(10,$msg4yposition)
$label4.Size = New-Object System.Drawing.Size(400,20)
$label4.Text = $msg4
$form.Controls.Add($label4)

$label5 = New-Object System.Windows.Forms.Label
$label5.Location = New-Object System.Drawing.Point(10,$msg5yposition)
$label5.Size = New-Object System.Drawing.Size(400,20)
$label5.Text = $msg5
$form.Controls.Add($label5)

$label6 = New-Object System.Windows.Forms.Label
$label6.Location = New-Object System.Drawing.Point(10,$msg6yposition)
$label6.Size = New-Object System.Drawing.Size(400,20)
$label6.Text = $msg6
$form.Controls.Add($label6)

$label7 = New-Object System.Windows.Forms.Label
$label7.Location = New-Object System.Drawing.Point(10,$msg7yposition)
$label7.Size = New-Object System.Drawing.Size(400,20)
$label7.Text = $msg7
$form.Controls.Add($label7)

$label8 = New-Object System.Windows.Forms.Label
$label8.Location = New-Object System.Drawing.Point(10,$msg8yposition)
$label8.Size = New-Object System.Drawing.Size(400,20)
$label8.Text = $msg8
$form.Controls.Add($label8)

$label9 = New-Object System.Windows.Forms.Label
$label9.Location = New-Object System.Drawing.Point(10,$msg9yposition)
$label9.Size = New-Object System.Drawing.Size(400,20)
$label9.Text = $msg9
$form.Controls.Add($label9)

$label10 = New-Object System.Windows.Forms.Label
$label10.Location = New-Object System.Drawing.Point(10,$msg10yposition)
$label10.Size = New-Object System.Drawing.Size(400,20)
$label10.Text = $msg10
$form.Controls.Add($label10)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::Cancel)

{

Exit

}
###stop###>

#######################################################################################
# Outline Requirements 
#######################################################################################

Write-Host -ForegroundColor Green "
This script will do the following:"

Write-Host -ForegroundColor White "
- Deploy HCX Connector to the on-premises VMware cluster which has the VMs that will be migrating to AVS.
"

Write-Host -ForegroundColor Green "
To support this deployment the following is required on your local system:
"

Write-Host -ForegroundColor White "- Pre-Populated Configuraton File"
Write-Host -ForegroundColor Yellow "  https://github.com/Trevor-Davis/scripts/blob/main/Nested_Cluster_Deploy/nestedlabvariables.xlsx"
Write-Host -ForegroundColor White "- Microsoft Excel"
Write-Host -ForegroundColor White "- HCX Connector OVA file (Can be downloaded from the HCX Manager in AVS)"

Write-Host -ForegroundColor Yellow "Would you like to begin? (Y/N): " -NoNewline
$begin = Read-Host 

if ("n" -eq $begin) {
  Exit-PSSession}

#######################################################################################
# Check for Installs
#######################################################################################
if ($PSVersionTable.PSVersion.Major -lt 7){
  Write-Host -ForegroundColor Red "Please upgrade Powershell to 7.x"
  Exit-PSSession
}

$vmwarepowerclicheck = Find-Module -Name VMware.PowerCLI
if ($vmwarepowerclicheck.Name -ne "VMware.PowerCLI") {
  Write-Host -ForegroundColor Red "Please install the VMware.PowerCLI Module"
  Exit-PSSession
  
}

$vmwarepowerclicheck = Find-Module -Name VMware.VimAutomation.Hcx
if ($vmwarepowerclicheck.Name -ne "VMware.VimAutomation.Hcx") {
  Write-Host -ForegroundColor Red "Please install the VMware.VimAutomation.Hcx Module"
  Exit-PSSession
  }

#######################################################################################
# Browse for User Input File 
#######################################################################################
Clear-Host
Write-Host -ForegroundColor Yellow "You will now be asked to locate the file" -NoNewline
Write-Host -ForegroundColor Red " hcx.xlsx " -NoNewline
Write-Host -ForegroundColor Yellow "on your local system.  Press any key to continue ..."
$readhost = Read-Host 

   Add-Type -AssemblyName System.Windows.Forms
   $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
   [void]$FileBrowser.ShowDialog()
   
   $file = $FileBrowser.FileName

# $file = "C:\Users\avs-admin\Downloads\nested\nestedlabvariables.xlsx"

$sheetName = "hcx"
   $objExcel = New-Object -ComObject Excel.Application
   $workbook = $objExcel.Workbooks.Open($file)
   $sheet = $workbook.Worksheets.Item($sheetName)
   $objExcel.Visible=$false

   #Declare the  positions
   $rowOnPremVIServerIP,$colOnPremVIServerIP = 8,4
$rowOnPremVIServerUsername,$colOnPremVIServerUsername = 9,4
$rowOnPremVIServerPassword,$colOnPremVIServerPassword = 10,4
$rowPSCIP,$colPSCIP = 11,4
$rowOnPremCluster,$colOnPremCluster = 12,4
$rowVMNetwork,$colVMNetwork = 13,4
$rowDatastore,$colDatastore = 14,4
$rowHCXVMIP,$colHCXVMIP = 15,4
$rowHCXVMNetmask ,$colHCXVMNetmask  = 16,4
$rowHCXVMGateway,$colHCXVMGateway = 17,4
$rowHCXVMDNS,$colHCXVMDNS = 18,4
$rowHCXVMDomain,$colHCXVMDomain = 19,4
$rowAVSVMNTP,$colAVSVMNTP = 20,4
$rowHCXOnPremPassword,$colHCXOnPremPassword = 21,4
$rowHCXOnPremLocation,$colHCXOnPremLocation = 22,4
$rowhcxactivationkey,$colhcxactivationkey = 23,4


$rowHCXCloudIP,$colHCXCloudIP = 26,4
$rowHCXCloudPassword,$colHCXCloudPassword = 27,4


$rowvmotionportgroup,$colvmotionportgroup = 30,4
$rowvmotionprofilegateway,$colvmotionprofilegateway = 31,4
$rowvmotionnetworkmask,$colvmotionnetworkmask = 32,4
$rowvmotionippool,$colvmotionippool = 33,4
$rowmanagementportgroup,$colmanagementportgroup = 34,4
$rowmgmtprofilegateway,$colmgmtprofilegateway = 35,4
$rowmgmtnetworkmask,$colmgmtnetworkmask = 36,4
$rowmgmtippool,$colmgmtippool = 37,4
$rowhcxVDS,$colhcxVDS = 38,4
$rowHCXOnPremUserID,$colHCXOnPremUserID = 39,4
$rowHCXManagerVMName,$colHCXManagerVMName = 40,4
$rowHCXOnPremRoleMapping,$colHCXOnPremRoleMapping = 41,4
$rowmgmtnetworkprofilename,$colmgmtnetworkprofilename = 42,4
$rowvmotionnetworkprofilename,$colvmotionnetworkprofilename = 43,4
$rowhcxactivationurl,$colhcxactivationurl = 44,4
$rowHCXCloudUserID,$colHCXCloudUserID = 45,4
$rowhcxComputeProfileName,$colhcxComputeProfileName = 46,4
$rowhcxServiceMeshName,$colhcxServiceMeshName = 47,4
$rowhcxRemoteComputeProfileName,$colhcxRemoteComputeProfileName = 48,4


    
   #read in variables
   $OnPremVIServerIP = $sheet.Cells.Item($rowOnPremVIServerIP,$colOnPremVIServerIP).text
   $OnPremVIServerUsername = $sheet.Cells.Item($rowOnPremVIServerUsername,$colOnPremVIServerUsername).text
   $OnPremVIServerPassword = $sheet.Cells.Item($rowOnPremVIServerPassword,$colOnPremVIServerPassword).text
   $PSCIP = $sheet.Cells.Item($rowPSCIP,$colPSCIP).text
   $OnPremCluster = $sheet.Cells.Item($rowOnPremCluster,$colOnPremCluster).text
   $VMNetwork = $sheet.Cells.Item($rowVMNetwork,$colVMNetwork).text
   $Datastore = $sheet.Cells.Item($rowDatastore,$colDatastore).text
   $HCXVMIP = $sheet.Cells.Item($rowHCXVMIP,$colHCXVMIP).text
   $HCXVMNetmask  = $sheet.Cells.Item($rowHCXVMNetmask ,$colHCXVMNetmask ).text
   $HCXVMGateway = $sheet.Cells.Item($rowHCXVMGateway,$colHCXVMGateway).text
   $HCXVMDNS = $sheet.Cells.Item($rowHCXVMDNS,$colHCXVMDNS).text
   $HCXVMDomain = $sheet.Cells.Item($rowHCXVMDomain,$colHCXVMDomain).text
   $AVSVMNTP = $sheet.Cells.Item($rowAVSVMNTP,$colAVSVMNTP).text
   $HCXOnPremPassword = $sheet.Cells.Item($rowHCXOnPremPassword,$colHCXOnPremPassword).text
   $HCXOnPremLocation = $sheet.Cells.Item($rowHCXOnPremLocation,$colHCXOnPremLocation).text
   $hcxactivationkey = $sheet.Cells.Item($rowhcxactivationkey,$colhcxactivationkey).text
   
   
   $HCXCloudIP = $sheet.Cells.Item($rowHCXCloudIP,$colHCXCloudIP).text
   $HCXCloudPassword = $sheet.Cells.Item($rowHCXCloudPassword,$colHCXCloudPassword).text
   
   
   $vmotionportgroup = $sheet.Cells.Item($rowvmotionportgroup,$colvmotionportgroup).text
   $vmotionprofilegateway = $sheet.Cells.Item($rowvmotionprofilegateway,$colvmotionprofilegateway).text
   $vmotionnetworkmask = $sheet.Cells.Item($rowvmotionnetworkmask,$colvmotionnetworkmask).text
   $vmotionippool = $sheet.Cells.Item($rowvmotionippool,$colvmotionippool).text
   $managementportgroup = $sheet.Cells.Item($rowmanagementportgroup,$colmanagementportgroup).text
   $mgmtprofilegateway = $sheet.Cells.Item($rowmgmtprofilegateway,$colmgmtprofilegateway).text
   $mgmtnetworkmask = $sheet.Cells.Item($rowmgmtnetworkmask,$colmgmtnetworkmask).text
   $mgmtippool = $sheet.Cells.Item($rowmgmtippool,$colmgmtippool).text
   $hcxVDS = $sheet.Cells.Item($rowhcxVDS,$colhcxVDS).text
   $HCXOnPremUserID = $sheet.Cells.Item($rowHCXOnPremUserID,$colHCXOnPremUserID).text
   $HCXManagerVMName = $sheet.Cells.Item($rowHCXManagerVMName,$colHCXManagerVMName).text
   $HCXOnPremRoleMapping = $sheet.Cells.Item($rowHCXOnPremRoleMapping,$colHCXOnPremRoleMapping).text
   $mgmtnetworkprofilename = $sheet.Cells.Item($rowmgmtnetworkprofilename,$colmgmtnetworkprofilename).text
   $vmotionnetworkprofilename = $sheet.Cells.Item($rowvmotionnetworkprofilename,$colvmotionnetworkprofilename).text
   $hcxactivationurl = $sheet.Cells.Item($rowhcxactivationurl,$colhcxactivationurl).text
   $HCXCloudUserID = $sheet.Cells.Item($rowHCXCloudUserID,$colHCXCloudUserID).text
   $hcxComputeProfileName = $sheet.Cells.Item($rowhcxComputeProfileName,$colhcxComputeProfileName).text
   $hcxServiceMeshName = $sheet.Cells.Item($rowhcxServiceMeshName,$colhcxServiceMeshName).text
   $hcxRemoteComputeProfileName = $sheet.Cells.Item($rowhcxRemoteComputeProfileName,$colhcxRemoteComputeProfileName).text
   
   

   #close excel file
   $objExcel.quit()


########################################
# Deploy HCX Connector
########################################
Write-Host "
"
Write-Host -NoNewLine -ForegroundColor White "
   You will now be asked to locate the"
   Write-Host -NoNewLine -ForegroundColor Green " HCX OVA file on your system.  This should have been downloaded from the Azure VMware Solution HCX Manager."
   Write-Host -NoNewline -ForegroundColor White "  Press any key to continue ..."

  

   Add-Type -AssemblyName System.Windows.Forms
   $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
   [void]$FileBrowser.ShowDialog()
   $HCXApplianceOVA = $FileBrowser.FileName


#$HCXApplianceOVA = "C:\users\avs-admin\Downloads\VMware-HCX-Connector-4.3.0.0-19068550.ova"

# Connect to vCenter



Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
Write-Host -ForegroundColor Green "Connecting to On-Premises vCenter Server..."
Connect-VIServer $OnPremVIServerIP -WarningAction SilentlyContinue -User $OnPremVIServerUsername -Password $OnPremVIServerPassword



# Load OVF/OVA configuration into a variable
$ovfconfig = Get-OvfConfiguration $HCXApplianceOVA


$VMHost = Get-Cluster $OnPremCluster | Get-VMHost
$VMHost = $VMHost.Name.Get(0)

# | Sort-Object MemoryGB | Sort-Object -first 1
#$VMHost | Get-datastore | Sort FreeSpaceGB -Descending | Select -first 1


# Fill out the OVF/OVA configuration parameters

# vSphere Portgroup Network Mapping
$ovfconfig.NetworkMapping.VSMgmt.value = $VMNetwork

# IP Address
$ovfConfig.common.mgr_ip_0.value = $HCXVMIP

# Netmask
$ovfConfig.common.mgr_prefix_ip_0.value = $HCXVMNetmask

# Gateway
$ovfConfig.common.mgr_gateway_0.value = $HCXVMGateway

# DNS Server
$ovfConfig.common.mgr_dns_list.value = $HCXVMDNS

# DNS Domain
$ovfConfig.common.mgr_domain_search_list.value  = $HCXVMDomain

# Hostname
$ovfconfig.Common.hostname.Value = $HCXManagerVMName

# NTP
$ovfconfig.Common.mgr_ntp_list.Value = $AVSVMNTP

# SSH
$ovfconfig.Common.mgr_isSSHEnabled.Value = $true

# Password
$ovfconfig.Common.mgr_cli_passwd.Value = $HCXOnPremPassword
$ovfconfig.Common.mgr_root_passwd.Value = $HCXOnPremPassword

# Deploy the OVF/OVA with the config parameters
Write-Host -ForegroundColor Green "Deploying HCX Connector OVA ..."
$vm = Import-VApp -Source $HCXApplianceOVA -OvfConfiguration $ovfconfig -Name $HCXManagerVMName -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin


<###

#########################
# Only do this for internal testing
#########################

$HCXVMIP = "192.168.89.152"
###>

#########################
# Wait for PowerOn
#########################

# Power On the HCX Connector VM after deployment
Write-Host -ForegroundColor Green "Powering on HCX Connector ..."
$vm | Start-VM -Confirm:$false | Out-Null
# Waiting for HCX Connector to initialize
while(1) {
    try {
        if($PSVersionTable.PSEdition -eq "Core") {
            $requests = Invoke-WebRequest -Uri "https://$($HCXVMIP):9443" -Method GET -SkipCertificateCheck -TimeoutSec 5
        } else {
            $requests = Invoke-WebRequest -Uri "https://$($HCXVMIP):9443" -Method GET -TimeoutSec 5
        }
        if($requests.StatusCode -eq 200) {
            Write-Host -ForegroundColor Green "HCX Connector is now ready to be configured!"
            break
        }
    }
    catch {
        Write-Host -ForegroundColor Yellow "HCX Connector is not ready yet, sleeping for 60 seconds ..."
        Start-Sleep 60
    }
}


#########################################
# Encode the HCX On Prem credentials
#########################################

$HCXOnPremCredentials = "$HCXOnPremUserID"+":"+"$HCXOnPremPassword"
$HCXBytes = [System.Text.Encoding]::UTF8.GetBytes($HCXOnPremCredentials)
$HCXOnPremCredentialsEncoded =[Convert]::ToBase64String($HCXBytes)



######################################
# Get The Certificate From HCX Cloud
####################################
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")

$body = "{
    `"url`": `"$HCXCloudIP`"
  }
"

$response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/certificates -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json



##########################
# Encode The On-Prem vCenter Password
##########################
$HCXBytes = [System.Text.Encoding]::UTF8.GetBytes($OnPremVIServerPassword)
$OnPremVIServerPasswordEncoded =[Convert]::ToBase64String($HCXBytes)


##########################
# Connect HCX Connector to OnPrem Vcenter
##########################

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")

$body = "{
  `"data`": {
    `"items`": [
      {
        `"config`": {
          `"url`": `"$OnPremVIServerIP`",
          `"userName`": `"$OnPremVIServerUsername`",
          `"password`": `"$OnPremVIServerPasswordEncoded`"
        }
      }
    ]
  }
}"

$response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/vcenter -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json


##########################
# Define PSC
##########################

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")

$body = "{
    `"data`": {
        `"items`": [
            {
                `"config`": {
                    `"providerType`": `"PSC`",
                    `"lookupServiceUrl`": `"$PSCIP`"
                }
            }
        ]
    }
}"

$response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/lookupservice/ -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck

$response | ConvertTo-Json


######################################
# Define the Role Mapping
####################################

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json;charset=UTF-8")
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")

$body = "[
`n    {
`n        `"role`": `"System Administrator`",
`n        `"userGroups`": [
`n            `"$HCXOnPremRoleMapping`\`\Administrators`"
`n        ]
`n    },
`n    {
`n        `"role`": `"Enterprise Administrator`",
`n        `"userGroups`": []
`n    }
`n]"

$response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/roleMappings -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json



#########################
# Retrieve Location 
#########################

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")

$location = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/searchCities?searchString=$HCXOnPremLocation -Method 'GET' -Headers $headers -Body $body -SkipCertificateCheck
$location | ConvertTo-Json
$locationcount = $location.items.Count

if ($locationcount -eq 1 ) {

$city = $location.items.city
$country = $location.items.country
$latitude = $location.items.latitude
$province = $location.items.province
$longitude = $location.items.longitude
    
}
else {
    
$city = $location.items.city.Item(0)
$country = $location.items.country.Item(0)
$latitude = $location.items.latitude.Item(0)
$province = $location.items.province.Item(0)
$longitude = $location.items.longitude.Item(0)
}

$body = "{
          `"city`": `"$city`",
          `"country`": `"$country`",
          `"latitude`": $latitude,
       `"province`": `"$province`",
        `"cityAscii`": `"$city`",
         `"longitude`": $longitude
    }"

$response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/location -Method 'PUT' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json


##########################
#Activate HCX
###########################
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Basic $HCXOnPremCredentialsEncoded")

$body = "{
      `"data`": {
        `"items`": [
          {
            `"config`": {
              `"url`": `"$hcxactivationurl`",
              `"activationKey`": `"$hcxactivationkey`"
            }
          }
        ]
      }
    }"

    
$response = Invoke-RestMethod https://$($HCXVMIP):9443/api/admin/global/config/hcx -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck
$response | ConvertTo-Json



################################
## login to HCX Connector and get the session info / Certificate for future API Call
###################################

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/json")

$body = "{
       `"username`": `"$OnPremVIServerUsername`",
       `"password`": `"$OnPremVIServerPassword`"
   }"
##This username and password combination is used because it's the same as the on-prem vcenter


$response = Invoke-RestMethod https://$($HCXVMIP)/hybridity/api/sessions -Method 'POST' -Headers $headers -Body $body -SkipCertificateCheck -SessionVariable 'Session'
$response | ConvertTo-Json
$session


######################################
# Connect To On Prem HCX Server
######################################
Connect-HCXServer -Server $HCXVMIP -User $OnPremVIServerUsername -Password $OnPremVIServerPassword

$command = New-HCXSitePairing -Url $HCXCloudIP -Username $HCXCloudUserID -Password $HCXCloudPassword 
$command | ConvertTo-Json

######################
# Create vMotion Netowrk Profile
######################

$vmotionnetworkbacking = Get-HCXNetworkBacking -Server $HCXVMIP -Name $vmotionportgroup 

$command = New-HCXNetworkProfile -PrimaryDNS "$HCXVMDNS" -DNSSuffix "$HCXOnPremRoleMapping" -Name "$vmotionnetworkprofilename" -GatewayAddress "$vmotionprofilegateway" -IPPool "$vmotionippool" -Network $vmotionnetworkbacking -PrefixLength "$vmotionnetworkmask"
$command | ConvertTo-Json


######################
# Create Management Netowrk Profile
######################




$mgmtnetworkbacking = Get-HCXNetworkBacking -Server $HCXVMIP -Name $managementportgroup 

$command = New-HCXNetworkProfile -PrimaryDNS "$HCXVMDNS" -DNSSuffix "$HCXOnPremRoleMapping" -Name "$mgmtnetworkprofilename" -GatewayAddress "$mgmtprofilegateway" -IPPool "$mgmtippool" -Network $mgmtnetworkbacking -PrefixLength "$mgmtnetworkmask"
$command | ConvertTo-Json



######################
# Create ComputeProfile
######################
#$managementNetworkProfile = Get-HCXNetworkProfile -Name $mgmtnetworkprofilename
#$vmotionNetworkProfile = Get-HCXNetworkProfile -Name $vmotionnetworkprofilename


$managementNetworkProfile = Get-HCXNetworkProfile -Name $mgmtnetworkprofilename
$vmotionNetworkProfile = Get-HCXNetworkProfile -Name $vmotionnetworkprofilename
$hcxComputeCluster = Get-HCXApplianceCompute -ClusterComputeResource
$hcxVDS = Get-HCXInventoryDVS -Name $hcxVDS
$hcxDatastore = Get-HCXApplianceDatastore -Compute $hcxComputeCluster -Name $Datastore

$command = New-HCXComputeProfile -Name $hcxComputeProfileName -ManagementNetworkProfile $managementNetworkProfile -vMotionNetworkProfile $vmotionNetworkProfile -DistributedSwitch $hcxVDS -Service BulkMigration,Interconnect,Vmotion,WANOptimization,NetworkExtension -Datastore $hcxDatastore -DeploymentResource $hcxComputeCluster -ServiceCluster $hcxComputeCluster
$command | ConvertTo-Json



###############
#Service Mesh
##########


$hcxDestinationSite = Get-HCXSite -Destination 
$hcxLocalComputeProfile = Get-HCXComputeProfile -Name $hcxComputeProfileName
$hcxRemoteComputeProfile = Get-HCXComputeProfile -Site $hcxDestinationSite -Name $hcxRemoteComputeProfileName

$command = New-HCXServiceMesh -Name $hcxServiceMeshName -SourceComputeProfile $hcxLocalComputeProfile -Destination $hcxDestinationSite -DestinationComputeProfile $hcxRemoteComputeProfile -Service BulkMigration,Interconnect,Vmotion,WANOptimization,NetworkExtension 
$command | ConvertTo-Json

###############
#Exit
##########

Write-Host -ForegroundColor Blue "HCX Is Now Deployed In Your On Premises Cluster, Log into your On-Premises vCenter and You Should See a HCX Plug-In, If You Do Not, Log Out of vCenter and Log Back In."
Write-Host -ForegroundColor White "Press Any Key To Continue"
$readhost = Read-Host 



Start-Process "https://$OnPremVIServerIP"