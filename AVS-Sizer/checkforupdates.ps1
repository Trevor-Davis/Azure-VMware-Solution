
. $downloaddirectory\currentversion.ps1
$global:updateflag = 1

$filename = "cloudversion.ps1"
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$filename" -OutFile $downloaddirectory\$filename 
. $downloaddirectory\$filename 

If ($cloudversion -gt $currentversion){


Write-Host "Your Version: $currentversion"
Write-Host "New Version: $cloudversion"
Write-Host "Release Notes: Converted memory calculation to MiB from MB to align with API sizing, default overcommit changed to 6:1 and cleaned up the powerpoint files formatting a bit" -ForegroundColor Yellow
$YesOrNo = Read-Host "There is a new version of the AVS-Sizer, would you like to Upgrade Now? (Y/N)"
write-host $YesOrNo
Read-Host

If ( $YesOrNo -eq "y")
{
.\avsinstall.ps1
}
}
else {
Write-Host "You Are Running the Latest AVS-Sizer
"   
}

$global:updateflag = 0

<#

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


foreach($filename in $filenames){

    $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}

##############
# Linuxandothersizing Directory
##############

$directory = "linuxandothersizing"

$filenames = @(
"linuxandotherVariables.ps1"
"av36plinuxandotherSizing.ps1"
"av52linuxandotherSizing.ps1"
"av64linuxandotherSizing.ps1"
)

foreach($filename in $filenames){
    $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}

##############
# sqlsizing Directory
##############

$directory = "sqlsizing"

$filenames = @(
"sqlVariables.ps1"
"av36pSQLSizing.ps1"
"av52SQLSizing.ps1"
"av64SQLSizing.ps1"
)

foreach($filename in $filenames){

    $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}

##############
# windowssizing Directory
##############

$directory = "windowssizing"

$filenames = @(
"WindowsVariables.ps1"
"av36pWindowsSizing.ps1"
"av52WindowsSizing.ps1"
"av64WindowsSizing.ps1"
)



foreach($filename in $filenames){
    $filename
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



foreach($filename in $filenames){
    $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}


}
}
#>