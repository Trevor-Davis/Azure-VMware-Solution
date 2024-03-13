
$theuser = $env:USERNAME
$thetime = Get-Date -Format "yyyy-MM-dd-HHmm"

$file = Set-Content $env:LOCALAPPDATA\$theuser-$thetime.txt $theuser-$thetime
$file = "$env:LOCALAPPDATA\$theuser-$thetime.txt"

#Get the File-Name without path
$name = (Get-Item $file).Name

#The target URL wit SAS Token
$uri = "https://avssizer.blob.core.windows.net/avsexecutionlogs/$($name)?sp=rcw&st=2024-03-12T01:11:14Z&se=2024-03-12T09:11:14Z&spr=https&sv=2022-11-02&sr=c&sig=IiGnzRoh7qzMvmnvLlM5K3ikUvG0mP%2FGYVejEfNWZCc%3D"

#Define required Headers
$headers = @{
    'x-ms-blob-type' = 'BlockBlob'
}

#Upload File...
Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $file