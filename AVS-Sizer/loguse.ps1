# https://rzander.azurewebsites.net/upload-file-to-azure-blob-storage-with-powershell/
    
$theuser = $env:USERNAME
$thetime = Get-Date -Format "yyyy-MM-dd-HHmm"
 
$file = Set-Content $env:LOCALAPPDATA\$theuser-$thetime.txt $theuser-$thetime
$file = "$env:LOCALAPPDATA\$theuser-$thetime.txt"

#Get the File-Name without path
$name = (Get-Item $file).Name

#The target URL wit SAS Token
$uri = "https://avssizer.blob.core.windows.net/avsexecutionlogs/$($name)?sp=ac&st=2024-03-13T16:11:03Z&se=2024-08-14T00:11:03Z&spr=https&sv=2022-11-02&sr=c&sig=EZGFbbXM2AsJTLx0GuThCoZt5Dm%2BICPayLcfg6bkN7M%3D"


#Define required Headers
$headers = @{
    'x-ms-blob-type' = 'BlockBlob'
}

#Upload File...
Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $file