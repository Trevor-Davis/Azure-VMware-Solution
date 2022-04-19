
  global:logintovcenter

  # Connect to vCenter

  Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore
  Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
  Connect-VIServer $OnPremVIServerIP -WarningAction SilentlyContinue -User $OnPremVIServerUsername -Password $OnPremVIServerPassword
  
  # Load OVF/OVA configuration into a variable
  $ovfconfig = Get-OvfConfiguration $HCXApplianceOVA
  $VMHost = Get-Cluster $OnPremCluster | Get-VMHost
  $VMHost = $VMHost.Name.Get(0)
  
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
  Write-Host -ForegroundColor Yellow "Deploying HCX Connector OVA ..."

  $requestvcenter = Invoke-WebRequest -Uri "https://$($OnPremVIServerIP):443" -Method GET -SkipCertificateCheck -TimeoutSec 5
  if ($requestvcenter.StatusCode -ne 200) {
write-Host -ForegroundColor Red "The machine this script is running from cannot reach the vCenter Server on port 443, please resolve this issue and re-run the script."
Exit
  }

  $requesthost = Test-Connection -IPv4 -TcpPort 902 $VMHost
  if ($requesthost -ne "True") {
write-Host -ForegroundColor Red "The machine this script is running from cannot reach the VMware environment on port 902 to deploy the OVA, please resolve this issue and re-run the script."
Exit
  }


  Import-VApp -Source $HCXApplianceOVA -OvfConfiguration $ovfconfig -Name $HCXManagerVMName -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin
  Write-Host -ForegroundColor Green "Success: HCX Connector Deployed to On-Premises Cluster"
