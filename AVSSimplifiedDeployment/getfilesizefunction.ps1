function getfilesize {

    param (
        $filename
    )
    ((Get-Item $filename).Length/1gb)
    
    }