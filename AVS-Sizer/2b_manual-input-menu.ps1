$global:locationofpowershell = $PSScriptRoot #This sets the location of all the pwoershell files to the root directory of this script.
$global:buttonclicked = ""

########################################################################################
# Generate the Form
########################################################################################

#Generates the Form
Add-type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing 


$formobject = [System.Windows.Forms.Form]
$labelobject = [System.Windows.Forms.Label]
$textinputobject = [System.Windows.Forms.TextBox]
$buttonobject = [System.Windows.Forms.Button]

$DefaultFont = 'Verdana,13'

##Setup Base Form
$AppForm = New-Object $formobject
$AppForm.ClientSize='800,450'
$AppForm.Text="AVS Sizer - Trevor Davis"
$AppForm.BackColor='#ffffff'
$AppForm.Font = $DefaultFont
$Appform.StartPosition = 'CenterScreen'

##Total VMs Input
$leftmargin = 30
$inputleftmargin = 350
$topmargin = 30

$totalvminputtext = New-Object $labelobject
$totalvminputtext.Text = "Total Number of Virtual Machines: "
$totalvminputtext.AutoSize=$true
$totalvminputtext.Location=New-Object System.Drawing.Point($leftmargin,$topmargin)   

$totalvminput = New-Object $textinputobject
$totalvminput.Width = '350'
$totalvminput.Location=New-Object System.Drawing.Point($inputleftmargin,$topmargin)
$totalvminput.AutoSize=$true

##Total Virtual CPUs
$leftmargin = 30
$inputleftmargin = 350
$topmargin = $topmargin+50

$totalvcpuinputtext = New-Object $labelobject
$totalvcpuinputtext.Text = "Total Number of Virtual CPUs: "
$totalvcpuinputtext.AutoSize=$true
$totalvcpuinputtext.Location=New-Object System.Drawing.Point($leftmargin,$topmargin)   

$totalvcpuinput = New-Object $textinputobject
$totalvcpuinput.Width = '350'
$totalvcpuinput.Location=New-Object System.Drawing.Point($inputleftmargin,$topmargin)
$totalvcpuinput.AutoSize=$true

##Total Memory 
$leftmargin = 30
$inputleftmargin = 350
$topmargin = $topmargin+50

$totalmemoryinputtext = New-Object $labelobject
$totalmemoryinputtext.Text = "Total Memory (GB): "
$totalmemoryinputtext.AutoSize=$true
$totalmemoryinputtext.Location=New-Object System.Drawing.Point($leftmargin,$topmargin)   

$totalmemoryinput = New-Object $textinputobject
$totalmemoryinput.Width = '350'
$totalmemoryinput.Location=New-Object System.Drawing.Point($inputleftmargin,$topmargin)
$totalmemoryinput.AutoSize=$true

##Total Storage 
$leftmargin = 30
$inputleftmargin = 350
$topmargin = $topmargin+50

$totalstorageinputtext = New-Object $labelobject
$totalstorageinputtext.Text = "Total Storage (TB): "
$totalstorageinputtext.AutoSize=$true
$totalstorageinputtext.Location=New-Object System.Drawing.Point($leftmargin,$topmargin)   

$totalstorageinput = New-Object $textinputobject
$totalstorageinput.Width = '350'
$totalstorageinput.Location=New-Object System.Drawing.Point($inputleftmargin,$topmargin)
$totalstorageinput.AutoSize=$true

#Submit Button
$leftmargin = 160
$inputleftmargin = 350
$topmargin = $topmargin+50

$submitButton = New-Object System.Windows.Forms.Button  
$submitButton.Location = New-Object System.Drawing.Point($leftmargin,$topmargin)  
$submitButton.Size = New-Object System.Drawing.Size(160,30)  
$submitButton.Text = "Submit"  
$submitButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$submitButton.add_Click({$global:buttonclicked = "submit"})

#Cancel Button
$leftmargin = 400
$inputleftmargin = 390
$topmargin = $topmargin
  
$cancelButton = New-Object $buttonobject
$cancelButton.Location = New-Object System.Drawing.Point($leftmargin,$topmargin)  
$cancelButton.Size = New-Object System.Drawing.Size(160,30)   
$cancelButton.Text = 'Cancel'  
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$cancelButton.add_Click({$global:buttonclicked = "Cancel"})


$AppForm.Controls.AddRange(@($cancelButton,$submitButton,$totalvminputtext,$totalvminput,$totalvcpuinput,$totalvcpuinputtext,$totalmemoryinput,$totalmemoryinputtext,$totalstorageinput,$totalstorageinputtext)) 

#Show The Form
$AppForm.ShowDialog()


########################################################################################
# Read The Form
########################################################################################

#the following two items are read from the form into variables to be used in the API POST


If($global:buttonclicked -eq "submit"){
    

$global:totalVMCount = $totalvminput.Text
$global:vCpuPerVM = ($totalvcpuinput.Text)/$global:totalVMCount
$global:vCpuTotal = $totalvcpuinput.Text
$global:storagePerVM = ([int]$totalstorageinput.Text*1024)/$global:totalVMCount
$global:storagePerVMTotal = $totalstorageinput.Text
$global:vRamPerVM = $totalmemoryinput.Text/$global:totalVMCount
$global:vRamPerVMTotal = $totalmemoryinput.Text


.\3_manual-avssizer-script.ps1

}