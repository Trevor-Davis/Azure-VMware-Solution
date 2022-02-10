$deployvariablesvariables = Invoke-WebRequest https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-PC-HCX-Networking-FULL/avspcdeploy-variables.ps1
Invoke-Expression $($deployvariablesvariables.Content)

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