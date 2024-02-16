$global:currentversion = 7.1

$downloaddirectory = "$env:HOMEPATH\Documents\avssizer"

$filename = "cloudversion.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$filename" -OutFile $downloaddirectory\$filename 

. $downloaddirectory\$filename 

If ($cloudversion -gt $currentversion)
{
    "There is a new version"
}

$global:apiurl = "https://vmc.vmware.com/api/vmc-sizer/v5/recommendation?vmPlacement=false"
$global:apiurlstaging = "https://stg.skyscraper.vmware.com/api/vmc-sizer/v5/recommendation"
$global:filename = "sizer.xlsm" # this is the filename of the sizer file
$global:buttonclicked = ""

