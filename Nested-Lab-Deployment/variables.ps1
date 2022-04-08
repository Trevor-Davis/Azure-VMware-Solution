#########################################
# Variables
#########################################
$global:nsxtusername = "admin"
$global:nsxtpassword = "!q9dy46!1sIC"
$global:nsxtip = "192.168.0.3"
$global:NestedBuildName = "NestedLab2"
$global:transportzone = "9a8f04f3-d09b-43f3-ae62-3fd3616edaa9"
$global:vlanid = "74"



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