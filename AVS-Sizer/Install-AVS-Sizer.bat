curl https://raw.githubusercontent.com/Trevor-Davis/Azure-VMware-Solution/master/AVS-Sizer/avsinstall.ps1 --output %userprofile%\Downloads\avsinstall.ps1
cd \%userprofile%\Downloads\
powershell.exe -ExecutionPolicy Bypass -File .\avsinstall.ps1