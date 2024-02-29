Clear-Host

$global:newinstallfile = 1



if ($newinstallfile -eq 1)

{
    $downloaddirectory = "$env:HOMEPATH\AppData\Local\avssizer"
    $filenames = @("avsinstall.ps1")
    foreach($filename in $filenames){

        Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$filename" -OutFile $downloaddirectory\$filename
        }

        

} 