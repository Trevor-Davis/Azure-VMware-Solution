
  global:logintovcenter

  
  # Load OVF/OVA configuration into a variable
  $ovfconfig = Get-OvfConfiguration $pfsensefilename2
  
  # Fill out the OVF/OVA configuration parameters
  
  # vSphere Portgroup Network Mapping
  $ovfconfig.NetworkMapping.NestedLab2_WANSwitch.value = $wannetwork 
  

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

  
  #########################
  # Wait for PowerOn
  #########################
  

  # Power On the HCX Connector VM after deployment
  Write-Host -ForegroundColor Yellow "Powering on HCX Connector ..."
  Start-VM -VM $HCXManagerVMName -Confirm:$false
  Clear-Host
  # Waiting for HCX Connector to initialize
  while(1) {
      try {
          if($PSVersionTable.PSEdition -eq "Core") {
              $requests = Invoke-WebRequest -Uri "https://$($HCXVMIP):9443" -Method GET -SkipCertificateCheck -TimeoutSec 5
          } else {
              $requests = Invoke-WebRequest -Uri "https://$($HCXVMIP):9443" -Method GET -TimeoutSec 5
          }
          if($requests.StatusCode -eq 200) {
              Write-Host -ForegroundColor Green "Success: HCX Connector is now ready to be configured!"
              break
          }
      }
      catch {
          Write-Host -ForegroundColor Yellow "Powering On HCX Connector ... Still Getting Ready ... Will Check Again In 1 Minute ..."
          Start-Sleep 60
      }
  }