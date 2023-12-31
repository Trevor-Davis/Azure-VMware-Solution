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
$comboboxobject = [System.Windows.Forms.ComboBox]
$buttonobject = [System.Windows.Forms.Button]

$DefaultFont = 'Verdana,13'

##Setup Base Form
$AppForm = New-Object $formobject
$AppForm.ClientSize='700,400'
$AppForm.Text="AVS Sizer - Trevor Davis"
$AppForm.BackColor='#ffffff'
$AppForm.Font = $DefaultFont
$Appform.StartPosition = 'CenterScreen'


##Dedupe Compression Selection
$leftmargin = 30
$dropdownleftmargin = 300
$dropdownrowtopmargin = 30
$textrowtopmargin = 60

$dedupecompressionitem = New-Object $labelobject
$dedupecompressionitem.Text = "Dedupe/Compression Ratio: "
$dedupecompressionitem.AutoSize=$true
$dedupecompressionitem.Location=New-Object System.Drawing.Point($leftmargin,$dropdownrowtopmargin)   

<#
$dedupecompressionnote = New-Object $labelobject
$dedupecompressionnote.Text = "The assumed dedupe/compression ratio of the environment."
$dedupecompressionnote.AutoSize=$true
$dedupecompressionnote.ForeColor = "Blue"
$dedupecompressionnote.Location=New-Object System.Drawing.Point($leftmargin,$textrowtopmargin)  
#>

$dedupecompressiondropdown = New-Object $comboboxobject
$dedupecompressiondropdown.Width = '350'
$dedupecompressiondropdown.Location=New-Object System.Drawing.Point($dropdownleftmargin,$dropdownrowtopmargin)
$dedupecompressiondropdown.AutoSize=$true
$dedupecompressiondropdown.SelectedText="1.25"
Import-Csv "C:\Users\tredavis\OneDrive - Microsoft\GitHub\Azure VMware Solution\AVS-Sizer\dev\dedupecompression.csv" | ForEach-Object {$dedupecompressiondropdown.Items.Add($_.'Dedupe/Compression')}

##FTT Raid Selection
$dropdownrowtopmargin = $dropdownrowtopmargin+70
$textrowtopmargin = $textrowtopmargin+70

$fttraiditem = New-Object $labelobject
$fttraiditem.Text = "FTT/RAID: "
$fttraiditem.AutoSize=$true
$fttraiditem.Location=New-Object System.Drawing.Point($leftmargin,$dropdownrowtopmargin)   

<#
$fttraidnote = New-Object $labelobject
$fttraidnote.Text = "This is Text"
$fttraidnote.AutoSize=$true
$fttraidnote.Location=New-Object System.Drawing.Point($leftmargin,$textrowtopmargin)  
#>

$fttraiddropdown = New-Object $comboboxobject
$fttraiddropdown.Width = '350'
$fttraiddropdown.Location=New-Object System.Drawing.Point($dropdownleftmargin,$dropdownrowtopmargin)
$fttraiddropdown.AutoSize=$true
$fttraiddropdown.SelectedText="AUTO"
Import-Csv "C:\Users\tredavis\OneDrive - Microsoft\GitHub\Azure VMware Solution\AVS-Sizer\dev\fttraid.csv" | ForEach-Object {$fttraiddropdown.Items.Add($_.'fttraid')}

# vCPU:pCPU Overcommit
$dropdownrowtopmargin = $dropdownrowtopmargin+70
$textrowtopmargin = $textrowtopmargin+70

$cpuovercommititem = New-Object $labelobject
$cpuovercommititem.Text = "vCPU:pCPU Overcommit: "
$cpuovercommititem.AutoSize=$true
$cpuovercommititem.Location=New-Object System.Drawing.Point($leftmargin,$dropdownrowtopmargin)   

<#
$cpuovercommitnote = New-Object $labelobject
$cpuovercommitnote.Text = "This is Text"
$cpuovercommitnote.AutoSize=$true
$cpuovercommitnote.Location=New-Object System.Drawing.Point($leftmargin,$textrowtopmargin)  
#>

$cpuovercommitdropdown = New-Object $comboboxobject
$cpuovercommitdropdown.Width = '350'
$cpuovercommitdropdown.Location=New-Object System.Drawing.Point($dropdownleftmargin,$dropdownrowtopmargin)
$cpuovercommitdropdown.AutoSize=$true
$cpuovercommitdropdown.SelectedText="5"
Import-Csv "C:\Users\tredavis\OneDrive - Microsoft\GitHub\Azure VMware Solution\AVS-Sizer\dev\cpuovercommit.csv" | ForEach-Object {$cpuovercommitdropdown.Items.Add($_.'cpuovercommit')}


#Go Button
$dropdownrowtopmargin = $dropdownrowtopmargin+70
$textrowtopmargin = $textrowtopmargin+70  
$leftmargin = $leftmargin +180

$goButton = New-Object System.Windows.Forms.Button  
$goButton.Location = New-Object System.Drawing.Point($leftmargin,$dropdownrowtopmargin)  
$goButton.Size = New-Object System.Drawing.Size(75,23)  
$goButton.Text = "Start"  
$goButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$goButton.add_Click({$global:buttonclicked = "Start"})

#Cancel Button
$dropdownrowtopmargin = $dropdownrowtopmargin
$textrowtopmargin = $textrowtopmargin+70
$leftmargin = $leftmargin +200
  
$cancelButton = New-Object $buttonobject
$cancelButton.Location = New-Object System.Drawing.Point($leftmargin,$dropdownrowtopmargin)  
$cancelButton.Size = New-Object System.Drawing.Size(75,23)  
$cancelButton.Text = 'Cancel'  
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$cancelButton.add_Click({$global:buttonclicked = "Cancel"})

##Notice
$dropdownrowtopmargin = $dropdownrowtopmargin+70
$textrowtopmargin = $textrowtopmargin - 65
$leftmargin = 30
$noticenote = New-Object $labelobject
$noticenote.Text = "Depending on the number of VMs in the RV Tools file this could take 
10-15 minutes to run."
$noticenote.AutoSize=$true
$noticenote.ForeColor = "Red"
$noticenote.Location=New-Object System.Drawing.Point($leftmargin,$textrowtopmargin)  


$AppForm.Controls.AddRange(@($goButton,$cancelButton,$dedupecompressionitem,$dedupecompressionnote,$dedupecompressiondropdown,$fttraiditem,$fttraidnote,$fttraiddropdown,$cpuovercommititem,$cpuovercommitnote,$cpuovercommitdropdown,$noticenote,$noticenote2)) 

#Show The Form
$AppForm.ShowDialog()


########################################################################################
# Read The Form
########################################################################################

#the following two items are read from the form into variables to be used in the API POST

$global:compressionRatio = $dedupecompressiondropdown.SelectedText
$global:computeOvercommitFactor = $cpuovercommitdropdown.SelectedText

# This section sets the fttftmtype variable to the appropriate text, the value in the form isn't what the POST requires.

if (
$fttraiddropdown.SelectedText -eq "FTT=1"
){
$global:fttFtmType = "FTT1_RAID1"
}

elseif (
$fttraiddropdown.SelectedText -eq "FTT=1, Erasure Coding"
){
    $global:fttFtmType = "FTT1_RAID5"
}

elseif (
$fttraiddropdown.SelectedText -eq "FTT=2"
){
    $global:fttFtmType = "FTT2_RAID1"
}

elseif (
$fttraiddropdown.SelectedText -eq "FTT=2, Erasure Coding"
){
    $global:fttFtmType = "FTT2_RAID6"
}

elseif (
$fttraiddropdown.SelectedText -eq "AUTO"
){
    $global:fttFtmType = "AUTO_AUTO"
}

########################################################################################
# Starts script
########################################################################################

If($global:buttonclicked -eq "Start"){

. $locationofpowershell\avssizer-script.ps1
}
