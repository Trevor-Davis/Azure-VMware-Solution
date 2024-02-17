
On Error Resume Next 
Set objShell = CreateObject("WScript.Shell")
objShell.Run("pwsh -noexit .\1_StartMenu.ps1")  
If Err.Number <> 0 Then
  WScript.Echo  ("It Appears You Don't Have PowerShell Version 7 Installed" & vbCrLf & "" & vbCrLf & "To Install PowerShell Version 7 Download It From Here;" & vbCrLf & "https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows")
  Err.Clear
End If