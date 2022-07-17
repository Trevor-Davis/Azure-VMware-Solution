function getfilesize {

    param (
        $filename
    )
    ((Get-Item $filename -ErrorAction SilentlyContinue).Length/1gb) 
        
    }