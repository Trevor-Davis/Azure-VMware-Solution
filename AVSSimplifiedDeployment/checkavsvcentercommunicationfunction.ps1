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