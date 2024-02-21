Clear-Host

$global:downloaddirectory = "$env:HOMEPATH\AppData\Local\avssizer"

if ($updateflag -ne 1)

{
    if (Test-Path $downloaddirectory) {
        Remove-Item $downloaddirectory -verbose -Confirm:$false -Force:$true -Recurse:$true
} 

}

write-host "Installing The AVS Sizer ... 
" 
$downloaddirectory = "$env:HOMEPATH\AppData\Local\avssizer"

if ($global:updateflag -ne 1)
{
Write-Host "Creating Directory:" $downloaddirectory
Write-host ""
mkdir $downloaddirectory
}

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
    "AVS-Sizer.zip"
    "checkforupdates.ps1"
    "check-importexcel.ps1"
    "check-powershell.ps1"
    "closesizerfile.ps1"
    "cloudversion.ps1"
    "currentversion.ps1"
    "globalvariables.ps1"
    if ($global:updateflag -ne 1){
    "avsinstall.ps1"}
    "Install-AVS-Sizer.bat"
    "opensizerfile.ps1"
    "sizer.xlsm"
    "StartAVSSizer.vbs"
    "variablesinventory.ps1"
    )

foreach($filename in $filenames){

Write-Host "Downloading File:" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$filename" -OutFile $downloaddirectory\$filename
}

##############
# AllInSizing Directory
##############
$directory = "allinsizing"
if ($updateflag -ne 1){
mkdir $downloaddirectory\$directory
}


$filenames = @(
"allinvariables.ps1"
"av36pAllInSizing.ps1"
"av52AllInSizing.ps1"
"av64AllInSizing.ps1"
)


foreach($filename in $filenames){

Write-Host "Downloading File:" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}


##############
# Linuxandothersizing Directory
##############

$directory = "linuxandothersizing"
if ($updateflag -ne 1){
mkdir $downloaddirectory\$directory
}
$filenames = @(
"linuxandotherVariables.ps1"
"av36plinuxandotherSizing.ps1"
"av52linuxandotherSizing.ps1"
"av64linuxandotherSizing.ps1"
)

foreach($filename in $filenames){
Write-Host "Downloading File:" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}

##############
# sqlsizing Directory
##############

$directory = "sqlsizing"
if ($updateflag -ne 1){
    mkdir $downloaddirectory\$directory
}
$filenames = @(
"sqlVariables.ps1"
"av36pSQLSizing.ps1"
"av52SQLSizing.ps1"
"av64SQLSizing.ps1"
)

foreach($filename in $filenames){

Write-Host "Downloading File:" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}

##############
# windowssizing Directory
##############

$directory = "windowssizing"
if ($updateflag -ne 1){
mkdir $downloaddirectory\$directory
}

$filenames = @(
"WindowsVariables.ps1"
"av36pWindowsSizing.ps1"
"av52WindowsSizing.ps1"
"av64WindowsSizing.ps1"
)



foreach($filename in $filenames){
Write-Host "Downloading File:" $filename

Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}


##############
# dropdowns
##############

$directory = "dropdowns"
if ($updateflag -ne 1){
mkdir $downloaddirectory\$directory
}

$filenames = @(
"cpuovercommit.csv"
"dedupecompression.csv"
"fttraid.csv"
"regions.csv"
"powerstate.csv"
)



foreach($filename in $filenames){
Write-Host "Downloading File:" $filename
Invoke-WebRequest -uri "https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/$directory/$filename" -OutFile $downloaddirectory\$directory\$filename

}

$global:desktopdirectory = [Environment]::GetFolderPath("Desktop")

Expand-Archive -LiteralPath $global:downloaddirectory\AVS-Sizer.zip -DestinationPath $global:downloaddirectory -Force

Copy-Item $global:downloaddirectory\AVS-Sizer.lnk $global:desktopdirectory

REad-Host "
AVS Sizer Is Installed, There Is a Shortcut on the Desktop Called ""AVS-Sizer""... Press Any Key To Continue"
Write-Host "
Cleaning Up Files ..."
Start-Sleep -Seconds 4