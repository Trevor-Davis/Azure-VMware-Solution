#########################################
# Variables
#########################################
$global:nsxtusername = "admin"
$global:nsxtpassword = "!q9dy46!1sIC"
$global:nsxtip = "192.168.0.3"


#########################################
# Encode the NSX-T Credentials
#########################################
  
  $global:nsxtcredentials = "$nsxtusername"+":"+"$nsxtpassword"
  $global:nsxbytes = [System.Text.Encoding]::UTF8.GetBytes($nsxtcredentials)
  $global:nsxtcredentialsencoded =[Convert]::ToBase64String($nsxbytes)

  Write-Host "hello"