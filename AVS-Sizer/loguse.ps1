# https://rzander.azurewebsites.net/upload-file-to-azure-blob-storage-with-powershell/
    
$theuser = $env:USERNAME
$thetime = Get-Date -Format "yyyy-MM-dd-HHmm"
 
$file = Set-Content $env:LOCALAPPDATA\$theuser-$thetime.txt $theuser-$thetime
$file = "$env:LOCALAPPDATA\$theuser-$thetime.txt"

#Get the File-Name without path
$name = (Get-Item $file).Name

#The target URL wit SAS Token
$uri = "https://tredavisavsgcs.blob.core.windows.net/avssizer/$($name)?sp=racw&st=2024-04-22T20:40:04Z&se=2025-04-23T04:40:04Z&spr=https&sv=2022-11-02&sr=c&sig=QnZoCCkVWO61Zs2al5iOSUQaDy2enOKFe1OmaBoAXVc%3D"


#Define required Headers
$headers = @{
    'x-ms-blob-type' = 'BlockBlob'
}

#Upload File...
Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $file