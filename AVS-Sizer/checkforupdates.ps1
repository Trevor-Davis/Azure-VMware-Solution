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

$filenames = "#StartAVSSizer.vbs", "1_StartMenu.ps1", "2a_avssizer-script.ps1", "2b_manual-input-menu.ps1"

foreach($filename in $filenames){
    Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$filename" -OutFile $downloaddirectory\$filename 
 
}
}