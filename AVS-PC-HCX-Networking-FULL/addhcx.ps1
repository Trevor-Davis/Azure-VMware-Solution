

write-Host -ForegroundColor Yellow "Deploying VMware HCX to the $pcname Private Cloud ... This will take approximately 45 minutes ... "
az vmware addon hcx create --resource-group "VirtualWorkloads-APAC-AzureCloud" --private-cloud "AVS1-VirtualWorkloads-APAC-AzureCloud" --offer "VMware MaaS Cloud Provider"
write-Host -ForegroundColor Green "Success: VMware HCX has been deployed to $pcname Private Cloud"
