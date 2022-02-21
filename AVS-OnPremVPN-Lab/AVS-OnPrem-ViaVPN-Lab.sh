## CLI deploy example deploying using a different VNET address space (Azure and On-premises)
#Variables
rg=VPN #Define your resource group
VMAdminUsername=avs-admin #specify your user
VMAdminPassword=Microsoft.123!
location=australiaeast #Set Region
mypip=$(curl ifconfig.io -s) #captures your local Public IP and adds it to NSG to restrict access to SSH only for your Public IP.
sharedkey=$(openssl rand -base64 24) #VPN Gateways S2S shared key is automatically generated.
ERenvironmentName=AVS #Set remove environment connecting via Expressroute (Example: AVS, Skytap, HLI, OnPremDC)
ERResourceID="/subscriptions/be8569eb-b087-4090-a1e2-ac12df4818d8/resourceGroups/tnt17-cust-p01-southeastasia/providers/Microsoft.Network/expressRouteCircuits/tnt17-cust-p01-southeastasia-er" ## ResourceID of your ExpressRoute Circuit.
UseAutorizationKey="Yes" #Use authorization Key, possible values Yes or No.
AutorizationKey="566c3b75-662b-4c28-9ae5-03cc76bfea14" #Only add ER Authorization Key if UseAutorizationKey=Yes
#Define emulated On-premises parameters:
OnPremName=OnPrem #On-premises Name
OnPremVnetAddressSpace=10.34.0.0/16 #On-premises VNET address space
OnPremSubnet1prefix=10.34.1.0/24 #On-premises Subnet1 address prefix
OnPremgatewaySubnetPrefix=10.34.2.0/24 #On-premises Gateways address prefix
OnPremgatewayASN=60010 #On-premises VPN Gateways ASN
#Define parameters for Azure Hub and Spokes:
AzurehubName=vNet-VPN-APAC-Hub #Azure Hub Name
AzurehubaddressSpacePrefix=10.12.0.0/16 #Azure Hub VNET address space
AzurehubNamesubnetName=subnet1 #Azure Hub Subnet name where VM will be provisioned
Azurehubsubnet1Prefix=10.12.1.0/24 #Azure Hub Subnet address prefix
AzurehubgatewaySubnetPrefix=10.12.1.1/24 #Azure Hub Gateway Subnet address prefix
AzurehubrssubnetPrefix=10.12.2.0/24 #Azure Hub Route Server subnet address prefix
AzureFirewallPrefix=10.12.3.0/24 #Azure Firewall Prefix
Azurespoke1Name=Az-Spk1 #Azure Spoke 1 name
Azurespoke1AddressSpacePrefix=10.13.0.0/16 # Azure Spoke 1 VNET address space
Azurespoke1Subnet1Prefix=10.13.1.0/24 # Azure Spoke 1 Subnet1 address prefix
Azurespoke2Name=Az-Spk2 #Azure Spoke 1 name
Azurespoke2AddressSpacePrefix=10.14.0.0/16 # Azure Spoke 1 VNET address space
Azurespoke2Subnet1Prefix=10.14.1.0/24 # Azure Spoke 1 VNET address space
#Parsing parameters above in Json format (do not change)
JsonAzure={\"hubName\":\"$AzurehubName\",\"addressSpacePrefix\":\"$AzurehubaddressSpacePrefix\",\"subnetName\":\"$AzurehubNamesubnetName\",\"subnet1Prefix\":\"$Azurehubsubnet1Prefix\",\"AzureFirewallPrefix\":\"$AzureFirewallPrefix\",\"gatewaySubnetPrefix\":\"$AzurehubgatewaySubnetPrefix\",\"rssubnetPrefix\":\"$AzurehubrssubnetPrefix\",\"spoke1Name\":\"$Azurespoke1Name\",\"spoke1AddressSpacePrefix\":\"$Azurespoke1AddressSpacePrefix\",\"spoke1Subnet1Prefix\":\"$Azurespoke1Subnet1Prefix\",\"spoke2Name\":\"$Azurespoke2Name\",\"spoke2AddressSpacePrefix\":\"$Azurespoke2AddressSpacePrefix\",\"spoke2Subnet1Prefix\":\"$Azurespoke2Subnet1Prefix\"}
JsonOnPrem={\"name\":\"$OnPremName\",\"addressSpacePrefix\":\"$OnPremVnetAddressSpace\",\"subnet1Prefix\":\"$OnPremSubnet1prefix\",\"gatewaySubnetPrefix\":\"$OnPremgatewaySubnetPrefix\",\"asn\":\"$OnPremgatewayASN\"}
az group create --name $rg --location $location
az deployment group create --name RSERVPNTransitLab-$location --resource-group $rg --template-uri https://raw.githubusercontent.com/dmauser/Lab/master/RS-ER-VPN-Gateway-Transit/azuredeploy.json --parameters VmAdminUsername=$VMAdminUsername VmAdminPassword=$VMAdminPassword gatewaySku=VpnGw1 vpnGatewayGeneration=Generation1 sharedKey=$sharedkey ExpressRouteEnvironmentName=$ERenvironmentName expressRouteCircuitID=$ERResourceID UseAutorizationKey=$UseAutorizationKey UseAutorizationKey=$UseAutorizationKey Onprem=$JsonOnPrem Azure=$JsonAzure --no-wait
#Check Deployment Status
az deployment group list -g $rg -o table