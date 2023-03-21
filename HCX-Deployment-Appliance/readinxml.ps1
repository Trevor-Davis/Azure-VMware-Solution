
#Any XML will do
$xml = Get-Content xmlexample.xml
#Find all nodes of type "Environment"
$xml | Select-Xml -Xpath "/Environment"