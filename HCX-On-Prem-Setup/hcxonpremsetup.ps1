#######################################################################################
# Connect to vCenter
#######################################################################################

$filename = "connectvcenter.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/VMwareScripts/master/$filename" -OutFile $env:TEMP\AVSDeploy\$filename
Invoke-Expression -Command $env:TEMP\AVSDeploy\$filename