# Author: Trevor Davis
# Website: www.virtualworkloads.com
# Twitter: vTrevorDavis
# This script can be used to deploy HCX to an on-prem location and fully connect and configure for use w/ an AVS Private Cloud
# For guidance on this script please refer to https://www.virtualworkloads.com 

$appliancefiledirectory = "c:\windows\temp\hcxappliance"

####################################################################
# Function - IfSelection
####################################################################

####################################################################
# Function - Write All Variables to File
####################################################################
$variablestorage = $appliancefiledirectory+"\hcxappliancevariables.ps1"

function updatevariablefile {
    param ()
    Remove-Item -Path $variablestorage
    Add-Content -path $variablestorage -value ('$global:sub = "'+($global:sub)+'"')
    Add-Content -path $variablestorage -value ('$global:pcname = "'+($global:pcname)+'"')
    Add-Content -path $variablestorage -value ('$global:pcrg = "'+($global:pcrg)+'"')
    Add-Content -path $variablestorage -value ('$global:OnPremVIServerIP = "'+($global:OnPremVIServerIP)+'"')
    Add-Content -path $variablestorage -value ('$global:OnPremVIServerUsername = "'+($global:OnPremVIServerUsername)+'"')
    Add-Content -path $variablestorage -value ('$global:OnPremVIServerPassword = "'+($global:OnPremVIServerPassword)+'"')
    Add-Content -path $variablestorage -value ('$global:OnPremCluster = "'+($global:OnPremCluster)+'"')
    Add-Content -path $variablestorage -value ('$global:datastore = "'+($global:datastore)+'"')
    Add-Content -path $variablestorage -value ('$global:VMNetwork = "'+($global:VMNetwork)+'"')
    Add-Content -path $variablestorage -value ('$global:HCXOnPremAdminPassword = "'+($global:HCXOnPremAdminPassword)+'"')
    Add-Content -path $variablestorage -value ('$global:HCXVMIP = "'+($global:HCXVMIP)+'"')
    Add-Content -path $variablestorage -value ('$global:HCXVMNetmask = "'+($global:HCXVMNetmask)+'"')
    Add-Content -path $variablestorage -value ('$global:HCXVMGateway = "'+($global:HCXVMGateway)+'"')
    Add-Content -path $variablestorage -value ('$global:HCXVMDNS = "'+($global:HCXVMDNS)+'"')
    Add-Content -path $variablestorage -value ('$global:HCXVMDomain = "'+($global:HCXVMDomain)+'"')
    Add-Content -path $variablestorage -value ('$global:ssodomain = "'+($global:ssodomain)+'"')
    Add-Content -path $variablestorage -value ('$global:ssogroup = "'+($global:ssogroup)+'"')
    Add-Content -path $variablestorage -value ('$global:HCXOnPremLocation = "'+($global:HCXOnPremLocation)+'"')
    Add-Content -path $variablestorage -value ('$global:managementportgroup = "'+($global:managementportgroup)+'"')
    Add-Content -path $variablestorage -value ('$global:mgmtprofilegateway = "'+($global:mgmtprofilegateway)+'"')
    Add-Content -path $variablestorage -value ('$global:mgmtnetworkmask = "'+($global:mgmtnetworkmask)+'"')
    Add-Content -path $variablestorage -value ('$global:mgmtippool = "'+($global:mgmtippool)+'"')
    Add-Content -path $variablestorage -value ('$global:l2extendedVDS = "'+($global:l2extendedVDS)+'"')

}

####################################################################
# Function - Main Menu
####################################################################

function mainmenu
{
    param (
        [string]$Title = 'Azure VMware Solution On-Prem HCX Deployment Appliance'
    )
    Clear-Host
    Write-Host "
    
================ $Title ================"
Write-Host -ForegroundColor Yellow "
1. Verify HCX Network Connectivity From On-Premises to Azure/AVS
2. Input HCX Deployment and Configuration Parameters for On-Premises Deployment
3. Kickoff On-Premises HCX Deployment and Configuration

0. Exit
"

Write-Host "
Selection: " -NoNewline
$Selection = Read-Host

if ($Selection -eq 1){menuverifyhcxconnectivity}
if ($Selection -eq 2){menuhcxparameters}
if ($Selection -eq 3){. $appliancefiledirectory\avshcxonpremsetup-forappliance.ps1}
if ($Selection -eq 0){exit}
}

####################################################################
# Function - menuverifyhcxconnectivity
####################################################################

function menuverifyhcxconnectivity
{
param ()
Clear-Host
Write-Host -foregroundcolor Yellow "
Please Provide The Following Parameters
======================================="
Write-Host "1. AVS Private Cloud Subscription ID: " -NoNewline 
write-host -foregroundcolor yellow "$($global:sub)"
Write-Host "2. AVS Private Cloud Name: " -NoNewline 
write-host -foregroundcolor yellow "$($global:pcname)"
Write-Host "3. AVS Private Cloud Resource Group: "  -NoNewline 
write-host -foregroundcolor yellow "$($global:pcrg)"
Write-Host "
R. Run The HCX Network Connectivity Check"
Write-Host "
0. Return to Main Menu"

Write-Host -foregroundcolor Yellow "
Select Item 1-3 To Edit or Make Another Selection: " -NoNewline
$Selection = Read-Host

If ($Selection -eq 1){
Write-Host "
AVS Private Cloud Subscription ID: " -NoNewline
$global:sub = Read-Host
updatevariablefile
menuverifyhcxconnectivity
}

If ($Selection -eq 2){
Write-Host "
AVS Private Cloud Name: " -NoNewline
$global:pcname = Read-Host
Add-Content -path $variablestorage -value ('$global:pcname = "'+($global:pcname)+'"')
menuverifyhcxconnectivity
}

If ($Selection -eq 3){
Write-Host "
AVS Private Cloud Resource Group:  " -NoNewline
$global:pcrg = Read-Host
Add-Content -path $variablestorage -value ('$global:pcrg = "'+($global:pcrg)+'"')
menuverifyhcxconnectivity
}

If ($Selection -eq "r"){
. $appliancefiledirectory\avshcxportcheck-forappliance.ps1
}
      
If ($Selection -eq 0){
mainmenu
}

If ($Selection -ne 1 -or $Selection -ne 2 -or $Selection -ne 3 -or $Selection -ne "r" -or $Selection -ne 0)
{
    menuverifyhcxconnectivity    
}
      
}

####################################################################
#   Function - hcxparameterlist
####################################################################

function hcxparameterlist {
    param ()
    

$global:hcxparameterslist = @(
@{Question=("AVS Private Cloud Information"); Variable=("")}
@{Question=("============================="); Variable=("")}
@{Question=("1. AVS Private Cloud Subscription ID: ");  Variable=($global:sub)}
@{Question=("2. AVS Private Cloud Name: ");             Variable=($global:pcname)}
@{Question=("3. AVS Private Cloud Resource Group: ");   Variable=($global:pcrg)}
@{Question=("");   Variable=("")}
@{Question=("On-Premises Information for HCX Manager Appliance Deployment");                 Variable=("")}
@{Question=("============================================================");                 Variable=("")}
@{Question=("4. vCenter Server IP: ");                  Variable=($global:OnPremVIServerIP)}
@{Question=("5. vCenter Server Username: ");            Variable=($global:OnPremVIServerUsername)}
@{Question=("6. vCenter Server Password: ");            Variable=($global:OnPremVIServerPassword)}
@{Question=("7. vSphere Cluster Name: ");               Variable=($global:OnPremCluster)}
@{Question=("8. Datastore: ");                          Variable=($global:datastore)}
@{Question=("9. Portgroup: ");                          Variable=($global:VMNetwork)}
@{Question=("");   Variable=("")}
@{Question=("HCX Manager Appliance Configuration Parameters");                 Variable=("")}
@{Question=("- All of These Values Will Be Assigned to the HCX Manager Deployed On-Premises -");                 Variable=("")}
@{Question=("================================================================================");                 Variable=("")}
@{Question=("10. Admin Password: ");                 Variable=($global:HCXOnPremAdminPassword)}
@{Question=("11. IP Address: ");                 Variable=($global:HCXVMIP)}
@{Question=("12. Netmask (Must be in /xx format, i.e., /24): ");                 Variable=($global:HCXVMNetmask)}
@{Question=("13. Gateway IP: ");                 Variable=($global:HCXVMGateway)}
@{Question=("14. DNS Server: ");                 Variable=($global:HCXVMDNS)}
@{Question=("15. Domain: ");                 Variable=($global:HCXVMDomain)}
@{Question=("16. On-Prem vCenter Server Platform Services Controller IP: ");                 Variable=($global:PSCIP)}
@{Question=("17. On-Prem vCenter Server SSO Domain (for initial setup its recommended use vsphere.local): ");                 Variable=($global:ssodomain)}
@{Question=("18. On-Prem vCenter Server Group for HCX Admins (for initial setup it's recommended to use Administrators): ");                 Variable=($global:ssogroup)}
@{Question=("19. HCX Manager On-Premises City: ");                 Variable=($global:HCXOnPremLocation)}
@{Question=("");   Variable=("")}
@{Question=("On-Prem Cluster Management Network Parameters");                 Variable=("")}
@{Question=("================================================================================");                 Variable=("")}
@{Question=("20. Cluster Management Network Portgroup: ");                 Variable=($global:managementportgroup)}
@{Question=("21. Cluster Management Network Gateway IP: ");                 Variable=($global:mgmtprofilegateway)}
@{Question=("22. Cluster Management Network Netmask (Must be in /xx format, i.e., /24): ");                 Variable=($global:mgmtnetworkmask)}
@{Question=("23. Cluster Management Network Free IPs (4 contiguous free IPs on the Cluster Management Network in this format x.x.x.x-x.x.x.x): ");                 Variable=($global:mgmtippool)}
@{Question=("");   Variable=("")}
@{Question=("L2 Extension");                 Variable=("")}
@{Question=("============");                 Variable=("")}
@{Question=("24. On-Prem Cluster Distributed Switch for L2 Extension: ");                 Variable=($global:l2extendedVDS)}
)
}

####################################################################
#   Function - MenuHCXParameters
####################################################################

function menuhcxparameters
{
param ()
Clear-Host
hcxparameterlist
foreach ($item in $hcxparameterslist) {
    write-host $item.Question -NoNewline
    write-host -ForegroundColor yellow $item.Variable
}
Write-Host "
0. Return to Main Menu"
Write-Host -foregroundcolor Yellow "
Select Item To Edit: " -NoNewline
$Selection = Read-Host

If ($Selection -eq 1){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:sub = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 2){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:pcname = Read-Host
updatevariablefile
menuhcxparameters}

If ($Selection -eq 3){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:pcrg = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 4){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:OnPremVIServerIP = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 5){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:OnPremVIServerUsername = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 6){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:OnPremVIServerPassword = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 7){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:OnPremCluster = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 8){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:datastore = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 9){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:VMNetwork = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 10){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:HCXOnPremAdminPassword = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 11){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:HCXVMIP = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 12){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:HCXVMNetmask = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 13){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:HCXVMGateway = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 14){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:HCXVMDNS = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 15){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:HCXVMDomain = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 16){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:PSCIP = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 17){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:ssodomain = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 18){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:ssogroup = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 19){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:HCXOnPremLocation = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 20){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:managementportgroup = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 21){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:mgmtprofilegateway = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 22){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:mgmtnetworkmask = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 23){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:mgmtippool = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 24){
Write-Host "
Input Value for " -NoNewline
Write-Host -foregroundcolor Yellow "Item $($Selection): " -NoNewline
$global:l2extendedVDS = Read-Host
updatevariablefile
menuhcxparameters
}

If ($Selection -eq 0){
mainmenu
}

If ($Selection -ne 1 -or $Selection -ne 2 -or $Selection -ne 3 -or $Selection -ne 4 -or $Selection -ne 5 -or $Selection -ne 6 `
-or $Selection -ne 7 -or $Selection -ne 8 -or $Selection -ne 9 -or $Selection -ne 10 -or $Selection -ne 11 -or $Selection -ne 12 `
-or $Selection -ne 13 -or $Selection -ne 14 -or $Selection -ne 15 -or $Selection -ne 16 -or $Selection -ne 17 -or $Selection -ne 18 `
-or $Selection -ne 19 -or $Selection -ne 20 -or $Selection -ne 21 -or $Selection -ne 22 -or $Selection -ne 23 -or $Selection -ne 24 `
-or $Selection -ne 0)
{
    menuhcxparameters
}
      
}


###################################################################

. $variablestorage
mainmenu