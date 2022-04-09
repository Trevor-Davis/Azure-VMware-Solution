#########################################
# Variables
#########################################
$global:nsxtusername = "admin"
$global:nsxtpassword = "!q9dy46!1sIC"
$global:nsxtip = "192.168.0.3"
$global:NestedBuildName = "NestedLab2"
$global:transportzone = "9a8f04f3-d09b-43f3-ae62-3fd3616edaa9"
$global:vlanid = "74"

$global:avsvcenterip = "192.168.0.2"
$global:avsvcenterusername = "cloudadmin@vsphere.local"
$global:avsvcenterpassword = "N-v9r2gR0%l8"
$global:avsclustername = "Cluster-1"
$global:avsclusterdatastore = "vsanDatastore"

$global:mgmtnetworkgateway = "10.35.0.1" #assumes /24 network
$global:wannetworkgateway = "10.35.1.1" #assumes /24 network


#########################################
# Encode the NSX-T Credentials
#########################################
  
  $global:nsxtcredentials = "$nsxtusername"+":"+"$nsxtpassword"
  $global:nsxbytes = [System.Text.Encoding]::UTF8.GetBytes($nsxtcredentials)
  $global:nsxtcredentialsencoded =[Convert]::ToBase64String($nsxbytes)

#########################################
# Functions
#########################################

function global:logintonsx {
  param (
  )

$global:headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$global:headers.Add("Authorization", "Basic $nsxtcredentialsencoded")
$global:headers.Add("Content-Type", "application/json")
}