Param(
  [Parameter(Mandatory=$true)]
  [string]$deploymentsteps,
  [string]$instructions,
  [string]$intro,
  [string]$customeremail
)

$Body = `
"`
`
$intro
`
$instructions
`
$deploymentsteps

"`

$password = ConvertTo-SecureString "1Billsdr#" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("trevor.davis@hotmail.com", $password)
Send-MailMessage -To $customeremail -From "trevor.davis@hotmail.com" -Subject "Custom AVS PowerShell Script For $Customer" -SmtpServer "smtp-mail.outlook.com" `
-Port 587 -UseSSL -Credential $Cred -ReplyTo "tredavis@microsoft.com" -Body $Body -Bcc "tredavis@microsoft.com"

