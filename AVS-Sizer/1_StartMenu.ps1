
    .\globalvariables.ps1  
    $global:manualsizing = 0     
    $global:locationofpowershell = $PSScriptRoot #This sets the location of all the pwoershell files to the root directory of this script.
    $global:sizerlocation = $locationofpowershell + "\" + $filename # this is the full path of the sizer file location


########################################################################################
# Check Pre-Reqs
########################################################################################

If ($testing -eq 1){

}
else {
  .\check-importexcel.ps1
  .\check-powershell.ps1
}


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

$DefaultFont = 'Aptos,13'

##Setup Base Form
$AppForm = New-Object $formobject
$AppForm.ClientSize='700,400'
$AppForm.Text="AVS Sizer - Trevor Davis"
$AppForm.BackColor='#ffffff'
$AppForm.Font = $DefaultFont
$Appform.StartPosition = 'CenterScreen'

##Instructions
$leftmargin = 30
$dropdownleftmargin = 300
$textrowtopmargin = 10

$instructions = New-Object $labelobject
$instructions.Text = "Modify the values as required, the values shown here are appropriate for most 
AVS sizing exercises."
$instructions.AutoSize=$true
$instructions.ForeColor = "Blue"
$instructions.Location=New-Object System.Drawing.Point($leftmargin,$textrowtopmargin)   


##Dedupe Compression Selection
$leftmargin = 30
$dropdownleftmargin = 300
$dropdownrowtopmargin = 80
$textrowtopmargin = 110

$dedupecompressionitem = New-Object $labelobject
$dedupecompressionitem.Text = "Dedupe/Compression Ratio: "
$dedupecompressionitem.AutoSize=$true
$dedupecompressionitem.Location=New-Object System.Drawing.Point($leftmargin,$dropdownrowtopmargin)   

$dedupecompressiondropdown = New-Object $comboboxobject
$dedupecompressiondropdown.Width = '350'
$dedupecompressiondropdown.Location=New-Object System.Drawing.Point($dropdownleftmargin,$dropdownrowtopmargin)
$dedupecompressiondropdown.AutoSize=$true
$dedupecompressiondropdown.SelectedText="1.25"
Import-Csv "$global:locationofpowershell\dropdowns\dedupecompression.csv" | ForEach-Object {$dedupecompressiondropdown.Items.Add($_.'Dedupe/Compression')}
 
##FTT Raid Selection
$dropdownrowtopmargin = $dropdownrowtopmargin+70
$textrowtopmargin = $textrowtopmargin+70

$fttraiditem = New-Object $labelobject
$fttraiditem.Text = "FTT/RAID: "
$fttraiditem.AutoSize=$true
$fttraiditem.Location=New-Object System.Drawing.Point($leftmargin,$dropdownrowtopmargin)   


$fttraiddropdown = New-Object $comboboxobject
$fttraiddropdown.Width = '350'
$fttraiddropdown.Location=New-Object System.Drawing.Point($dropdownleftmargin,$dropdownrowtopmargin)
$fttraiddropdown.AutoSize=$true
$fttraiddropdown.SelectedText="AUTO"
Import-Csv "$global:locationofpowershell\dropdowns\fttraid.csv" | ForEach-Object {$fttraiddropdown.Items.Add($_.'fttraid')}


# vCPU:pCPU Overcommit Selection
$dropdownrowtopmargin = $dropdownrowtopmargin+70
$textrowtopmargin = $textrowtopmargin+70

$cpuovercommititem = New-Object $labelobject
$cpuovercommititem.Text = "vCPU:pCPU Overcommit: "
$cpuovercommititem.AutoSize=$true
$cpuovercommititem.Location=New-Object System.Drawing.Point($leftmargin,$dropdownrowtopmargin)   

$cpuovercommitdropdown = New-Object $comboboxobject
$cpuovercommitdropdown.Width = '350'
$cpuovercommitdropdown.Location=New-Object System.Drawing.Point($dropdownleftmargin,$dropdownrowtopmargin)
$cpuovercommitdropdown.AutoSize=$true
$cpuovercommitdropdown.SelectedText="5"
Import-Csv "$global:locationofpowershell\dropdowns\cpuovercommit.csv" | ForEach-Object {$cpuovercommitdropdown.Items.Add($_.'cpuovercommit')}




#RVTools Button
$dropdownrowtopmargin = $dropdownrowtopmargin+70
$textrowtopmargin = $textrowtopmargin+70  
$leftmargin = $leftmargin 

$rvToolsButton = New-Object System.Windows.Forms.Button  
$rvToolsButton.Location = New-Object System.Drawing.Point($leftmargin,$dropdownrowtopmargin)  
$rvToolsButton.Size = New-Object System.Drawing.Size(160,30)  
$rvToolsButton.Text = "Import RV Tools"  
$rvToolsButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$rvToolsButton.add_Click({$global:buttonclicked = "rvtools"})


#Import Manually Button
$dropdownrowtopmargin = $dropdownrowtopmargin
$textrowtopmargin = $textrowtopmargin+70
$leftmargin = $leftmargin + 200
  
$manualimportButton = New-Object $buttonobject
$manualimportButton.Location = New-Object System.Drawing.Point($leftmargin,$dropdownrowtopmargin)  
$manualimportButton.Size = New-Object System.Drawing.Size(200,30)  
$manualimportButton.Text = 'Manually Input Data'  
$manualimportButton.DialogResult = [System.Windows.Forms.DialogResult]::Continue
$manualimportButton.add_Click({$global:buttonclicked = "manual"})


#Cancel Button
$dropdownrowtopmargin = $dropdownrowtopmargin
$textrowtopmargin = $textrowtopmargin+70
$leftmargin = $leftmargin + 240
  
$cancelButton = New-Object $buttonobject
$cancelButton.Location = New-Object System.Drawing.Point($leftmargin,$dropdownrowtopmargin)  
$cancelButton.Size = New-Object System.Drawing.Size(200,30)  
$cancelButton.Text = 'Cancel'  
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$cancelButton.add_Click({$global:buttonclicked = "Cancel"})


##Notice
$dropdownrowtopmargin = $dropdownrowtopmargin+70
$textrowtopmargin = $textrowtopmargin - 110
$leftmargin = 30
$noticenote = New-Object $labelobject
$noticenote.Text = "Depending on the number of VMs in the RV Tools file this could take 
10-15 minutes to run."
$noticenote.AutoSize=$true
$noticenote.ForeColor = "Red"
$noticenote.Location=New-Object System.Drawing.Point($leftmargin,$textrowtopmargin)  

$AppForm.Controls.AddRange(@($instructions,$cancelbutton,$rvToolsButton,$regionitem,$regiondropdown,$manualimportButton,$dedupecompressionitem,$dedupecompressionnote,$dedupecompressiondropdown,$fttraiditem,$fttraidnote,$fttraiddropdown,$cpuovercommititem,$cpuovercommitnote,$cpuovercommitdropdown,$noticenote,$noticenote2)) 

Clear-Host

#Show The Form
$AppForm.ShowDialog()


########################################################################################
# Read The Form
########################################################################################

#the following items are read from the form into variables to be used in the API POST

$global:compressionRatio = $dedupecompressiondropdown.SelectedText
$global:vcpupercore = $cpuovercommitdropdown.SelectedText
$global:computeOvercommitFactor = $cpuovercommitdropdown.SelectedText

if ($testing -eq 1){
.\variablesinventory.ps1
}

### This section sets the fttftmtype variable to the appropriate text, the value in the form isn't what the POST requires.


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

If($testing -eq 1){
write-host "FTT/RAID = $fttFtmType"
}
########################################################################################
# Starts script
########################################################################################

If($global:buttonclicked -eq "rvtools"){

.\2a_avssizer-script.ps1
} 

If ($global:buttonclicked -eq "manual") {

.\2b_manual-input-menu.ps1
}
 