Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer -Server $global:avsvcenterip -User $global:avsvcenterusername -Password $global:avsvcenterpassword 
$cluster = Get-Cluster -Name $global:avsclustername
New-VM -CD -Name "pfSense-$NestedBuildName" -Datastore $avsclusterdatastore -DiskGB 13 -DiskStorageFormat Thin -GuestId "freebsd12_64Guest" -MemoryGB 1 -NetworkName  