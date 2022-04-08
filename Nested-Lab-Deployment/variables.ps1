#########################################
# Variables
#########################################
$global:nsxtusername = "admin"
$global:nsxtpassword = "!q9dy46!1sIC"
$global:nsxtip = "192.168.0.3"
$global:NestedBuildName = "NestedLab2"


#########################################
# Encode the NSX-T Credentials
#########################################
  
  $global:nsxtcredentials = "$nsxtusername"+":"+"$nsxtpassword"
  $global:nsxbytes = [System.Text.Encoding]::UTF8.GetBytes($nsxtcredentials)
  $global:nsxtcredentialsencoded =[Convert]::ToBase64String($nsxbytes)

#########################################
# Functions
#########################################

function logintonsx {
  param (
  )

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic $nsxtcredentialsencoded")
$headers.Add("Content-Type", "application/json")
}