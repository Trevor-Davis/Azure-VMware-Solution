$RGNewOrExisting = "Existing"
$rgfordeployment = "VirtualWorkloads-APAC-AzureCloud"
$regionfordeployment = "southeastasia"

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