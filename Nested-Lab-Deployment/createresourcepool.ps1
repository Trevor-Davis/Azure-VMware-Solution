Connect-VIServer -Server $global:avsvcenterip -User $global:avsvcenterusername -Password $global:avsvcenterpassword
$cluster = Get-Cluster -Name $global:avsclustername
New-ResourcePool -Location $cluster -Name $NestedBuildName 