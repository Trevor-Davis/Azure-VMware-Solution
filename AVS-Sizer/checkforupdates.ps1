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

##############
# Base Directory
##############



    $filenames = @(
    "1_StartMenu.ps1"
    "2a_avssizer-script.ps1"
    "2b_manual-input-menu.ps1"
    "3_manual-avssizer-script.ps1"
    "apipost.ps1"
    "AVS.pptm"
    "checkforupdates.ps1"
    "check-importexcel.ps1"
    "check-powershell.ps1"
    "closesizerfile.ps1"
    "cloudversion.ps1"
    "currentversion.ps1"
    "globalvariables.ps1"
    "opensizerfile.ps1"
    "sizer.xlsm"
    "StartAVSSizer.vbs"
    "variablesinventory.ps1"
    )

$filenames

foreach($filename in $filenames){

$filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$filename" -OutFile $downloaddirectory\$filename
}
Read-Host

##############
# AllInSizing Directory
##############

$directory = "allinsizing"

$filenames = @(
"allinvariables.ps1"
"av36pAllInSizing.ps1"
"av52AllInSizing.ps1"
"av64AllInSizing.ps1"
)

$filenames

foreach($filename in $filenames){

Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}

##############
# Linuxandothersizing Directory
##############

$directory = "linuxandothersizing"

$filenames = @(
"linuxandothervariables.ps1"
"av36plinuxandotherSizing.ps1"
"av52linuxandotherSizing.ps1"
"av64linuxandotherSizing.ps1"
)

$filenames

foreach($filename in $filenames){

Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}

##############
# sqlsizing Directory
##############

$directory = "sqlsizing"

$filenames = @(
"sqlvariables.ps1"
"av36psqlSizing.ps1"
"av52sqlSizing.ps1"
"av64sqlSizing.ps1"
)

$filenames

foreach($filename in $filenames){

Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}

##############
# windowssizing Directory
##############

$directory = "windowssizing"

$filenames = @(
"windowsvariables.ps1"
"av36pwindowsSizing.ps1"
"av52windowsSizing.ps1"
"av64windowsSizing.ps1"
)

$filenames

foreach($filename in $filenames){

Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}


##############
# dropdowns
##############

$directory = "dropdowns"

$filenames = @(
"cpuovercommit.csv"
"dedupecompression.csv"
"fttraid.csv"
"regions.csv"
)

$filenames

foreach($filename in $filenames){

Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}









}