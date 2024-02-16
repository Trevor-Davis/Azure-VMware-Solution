$downloaddirectory = "$env:HOMEPATH\Documents\avssizer"
. $downloaddirectory\currentversion.ps1

write-host "the current version is" $currentversion

$filename = "cloudversion.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$filename" -OutFile $downloaddirectory\$filename 

. $downloaddirectory\$filename 

write-host "the cloud version is" $cloudversion

Read-Host


If ($cloudversion -gt $currentversion)
{
    "There is a new version"
    $filename = "globalvariables.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$filename" -OutFile $downloaddirectory\$filename 

}

$global:apiurl = "https://vmc.vmware.com/api/vmc-sizer/v5/recommendation?vmPlacement=false"
$global:apiurlstaging = "https://stg.skyscraper.vmware.com/api/vmc-sizer/v5/recommendation"
$global:filename = "sizer.xlsm" # this is the filename of the sizer file
$global:buttonclicked = ""

