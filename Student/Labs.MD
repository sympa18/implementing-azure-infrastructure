# Lab Open the Azure Portal and connect to Cloud Shell

Navigate to http://portal.azure.com so we can view the resources being created. 

You can access the Cloud Shell either within the Azure Portal by clicking the Cloud Shell Icon in the top right hand corner or in a tab on it's own. 

<figure>
        <img src="img/csicon.jpg" alt="Cloud Shell Icon" />
        <figcaption>Cloud Shell Icon</figcaption>
</figure>

In this lab we are going to open up a seperate tab.  
In a seperate tab navigate to http://shell.azure.com 

If this is the first time you ar opening the Cloud shell you may be asked to create a new storage account to attach to it. Follow the prompts to create it.

once on the Cloud Shell make sure you have selected PowerShell and not Bash.

# Lab Create a Resource Group

In this lab we will connect to our subscription and create two brand new resource groups

Since we already signed into the Cloud Shell we do not need to connect to our subscription. NOTE that the Cloud Shell does have a timeout of 20 minutes. Therefore a lot of the scripts we will be running in the labs will be seperated to avoid any timeouts.


Let's setup some variables for the location and the name of the resource groups.

Then let's create two new Resource Groups in seperate regions

Copy and paste the following code into the Cloud Shell Session

```
##########
##Step 1##
##########

##################################
##Create two new Resource Groups##
##################################

#setting variables for the Resource Group
$locationmel = "australiasoutheast"
$locationsyd = "australiaeast"
$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"

#Creating a new resource groups#
New-AzureRmResourceGroup -Name $rgnamemel -Location $locationmel
New-AzureRmResourceGroup -Name $rgnamesyd -Location $locationsyd


```

You should see a successfull output such as the code output below

#### Enter screenshot here

Jump into the Azure Portal and look for your new resource groups.

Further reading : 
https://docs.microsoft.com/en-us/azure/governance/policy/overview

Further reading : https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-lock-resources


# Lab Create a storage account

In this lab we will be creating a storage account and adding it to the existing resource groups we just created.

In Cloud Shell copy and paste the following code to 
* Specify the resurce group names 
* create two new variables for storage account names
* Run two commands to create the two storage accounts in two regions

```
##########
##Step 2##
##########

#Specifying location variables
$locationmel = "australiasoutheast"
$locationsyd = "australiaeast"

#specifying Resource Group variables
$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"

#Setting variables for the storage account#
$sasydname = "sasyd$(Get-Random)"
$samelname = "samel$(Get-Random)"

#Create new storage accounts
$sasyd = New-AzureRmStorageAccount -Location $locationsyd -Name $sasydname -ResourceGroupName $rgnamesyd -SkuName Standard_LRS -AccessTier Hot -Kind StorageV2
$samel = New-AzureRmStorageAccount -Location $locationmel -Name $samelname -ResourceGroupName $rgnamemel -SkuName Standard_LRS -AccessTier Hot -Kind StorageV2

```

Jump into the portal and ensure that the storage accounts have been created.


Further reading : https://docs.microsoft.com/en-us/azure/storage/common/storage-introduction


# Lab Create your Network

We want to create three VNET's in our environment. Two production VNET's in Melbourne and Sydney. One Dev VNET in Melbourne.

In Cloud Shell copy and paste the following commands to create the three VNET's

```
##########
##Step 3##
##########

################
##CREATE VNETS##
################

#Set Common variable#
$locationmel = "australiasoutheast"
$locationsyd = "australiaeast"
$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"

#Set Networking Variables for VNETMELPROD VNET#
$vnetmelprodAP = "12.0.0.0/24"
$vnetmelprodname = "VNETMELPROD"
$vnetmelprodsnname = "SNMELPROD"
$vnetmelprodsnAP = "12.0.0.0/25"
$vnetmelprodsngwname = "GatewaySubnet"
$vnetmelprodsngwAP = "12.0.0.224/27"

#Create VNETMELPROD Subnet configurations
$vnetmelprodsn = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $vnetmelprodsnAP -Name $vnetmelprodsnname
$vnetmelprodsngw = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $vnetmelprodsngwAP -Name $vnetmelprodsngwname

#Create the VNETMELPROD Virtual Network
$vnetmelprod = New-AzureRmVirtualNetwork -AddressPrefix $vnetmelprodAP -Location $locationmel -Name $vnetmelprodname -ResourceGroupName $rgnamemel -Subnet $vnetmelprodsn,$vnetmelprodsngw -Verbose


#Set Networking Variables for VNETMELDEV VNET#
$vnetmeldevAP = "13.0.0.0/24"
$vnetmeldevname = "VNETMELDEV"
$vnetmeldevsnname = "SNMELDEV"
$vnetmeldevsnAP = "13.0.0.0/25"

#Create VNETMELDEV Subnet configurations
$vnetmeldevsn = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $vnetmeldevsnAP -Name $vnetmeldevsnname

#Create the VNETMELDEV Virtual Network
$vnetmeldev = New-AzureRmVirtualNetwork -AddressPrefix $vnetmeldevAP -Location $locationmel -Name $vnetmeldevname -ResourceGroupName $rgnamemel -Subnet $vnetmeldevsn -Verbose


#Set Networking Variables for VNETSYDPRO VNET#
$vnetsydprodAP = "14.0.0.0/24"
$vnetsydprodname = "VNETSYDPROD"
$vnetsydprodsnname = "SNSYDPROD"
$vnetsydprodsnAP = "14.0.0.0/25"
$vnetsydprodsngwname = "GatewaySubnet"
$vnetsydprodsngwAP = "14.0.0.224/27"

#Create VNETSYDPRO Subnet configurations
$vnetsydprodsn = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $vnetsydprodsnAP -Name $vnetsydprodsnname
$vnetsydprodsngw = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $vnetsydprodsngwAP -Name $vnetsydprodsngwname

#Create the VNETSYDPRO Virtual Network
$vnetsydprod = New-AzureRmVirtualNetwork -AddressPrefix $vnetsydprodAP -Location $locationsyd -Name $vnetsydprodname -ResourceGroupName $rgnamesyd -Subnet $vnetsydprodsn -Verbose


```
While the commands are running jump into the Azure portal and watch the resources being created in your Resource Groups. VNETMELPROD and VNETMELDEV will be created in RGMELCONTOSO. VNETSYDPROD will be created in RGSYDCONTOSO.

# LAB Create VNET Peering 

Now that out VNET's have been created we want to connect them to each other, otherwise any virtual machine's we create inside them will not be able to communicate with each other.

Let's run some commands to create VNET peering between each of the VNET's. 

```
##########
##Step 4##
##########

#Peer the Sydney and Melbourne VNET's#
#first lets set some variables with each VNET's ID#
$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"
$vnetmelprodname = "VNETMELPROD"
$vnetmeldevname = "VNETMELDEV"
$vnetsydprodname = "VNETSYDPROD"
$vnetmelprod = Get-AzureRmVirtualNetwork -Name $vnetmelprodname -ResourceGroupName $rgnamemel
$vnetmeldev = Get-AzureRmVirtualNetwork -Name $vnetmeldevname -ResourceGroupName $rgnamemel
$vnetsydprod = Get-AzureRmVirtualNetwork -Name $vnetsydprodname -ResourceGroupName $rgnamesyd
$vnetmelprodid = ($vnetmelprod).Id
$vnetmeldevid = ($vnetmeldev).Id
$vnetsydprodid = ($vnetsydprod).Id

#Now let's add VNET Peering to each VNET#

$vnetpeeringsydprodtomelprod = Add-AzureRmVirtualNetworkPeering -Name vnetsydprodtovnetmelprod -RemoteVirtualNetworkId $vnetmelprodid -VirtualNetwork $vnetsydprod -AllowForwardedTraffic -Verbose
$vnetpeeringmelprodtosydprod = Add-AzureRmVirtualNetworkPeering -Name vnetmelprodtovnetsydprod -RemoteVirtualNetworkId $vnetsydprodid -VirtualNetwork $vnetmelprod -AllowForwardedTraffic -Verbose
$vnetpeeringmelprodtomeldev = Add-AzureRmVirtualNetworkPeering -Name vnetmelprodtovnetmeldev -RemoteVirtualNetworkId $vnetmeldevid -VirtualNetwork $vnetmelprod -AllowForwardedTraffic -Verbose
$vnetpeeringmeldevtomelprod = Add-AzureRmVirtualNetworkPeering -Name vnetmeldevtovnetmelprod -RemoteVirtualNetworkId $vnetmelprodid -VirtualNetwork $vnetmeldev -AllowForwardedTraffic -Verbose


```

If you check the peering section of each VNET you will notice that you should now have an active and connected PEER


# LAB add Network Security Groups

Let's now add some security to our VNET before we go ahead and add some Virtual Machines into the environment.
Run the following commands to add a NSG to each of the Subnet's in your VNET's. Note that we have added three rules to allow access to port's 3389 for RDP, 22 for SSH and 80 for HTTP. These rules are always blocked by default for security reason's. It is recommended that you only open certain ports in Dev/Test scenarios and not for a production environment.


```
##########
##Step 5##
##########

#Set common variables
$locationmel = "australiasoutheast"
$locationsyd = "australiaeast"
$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"
$vnetmelprodname = "VNETMELPROD"
$vnetmeldevname = "VNETMELDEV"
$vnetsydprodname = "VNETSYDPROD"

#Create an NSG for each Subnet

#Set the common  NSG Rules
$nsgruleallowrdp = New-AzureRmNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsgruleallowhttp = New-AzureRmNetworkSecurityRuleConfig -Name web-rule -Description "Allow HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80
$nsgruleallowssh = New-AzureRmNetworkSecurityRuleConfig -Name ssh-rule -Description "Allow SSH" -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22

#Create an NSG for VNETMELPRO
#Set the variables
$vnetmelprodsnname = "SNMELPROD"
$vnetmelprodsnAP = "12.0.0.0/25"
$vnetmelprod = Get-AzureRmVirtualNetwork -Name $vnetmelprodname  -ResourceGroupName $rgnamemel
$vnetmelprodnsgname = "VNETMELPRODNSG"

#Create the NSG
$vnetmelprodnsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgnamemel -Location $locationmel -Name $vnetmelprodnsgname -SecurityRules $nsgruleallowrdp,$nsgruleallowhttp,$nsgruleallowssh
#Assign the NSG to the SNMELPROD Subnet
$vnetmelprodsn = Set-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $vnetmelprodsnAP -Name $vnetmelprodsnname -VirtualNetwork $vnetmelprod -NetworkSecurityGroup $vnetmelprodnsg | Set-AzureRmVirtualNetwork

#Create an NSG for VNETMELDEV
#Set the variables
$vnetmeldevsnname = "SNMELDEV"
$vnetmeldevsnAP = "13.0.0.0/25"
$vnetmeldev = Get-AzureRmVirtualNetwork -Name $vnetmeldevname  -ResourceGroupName $rgnamemel
$vnetmeldevnsgname = "VNETMELDEVNSG"

#Create the NSG
$vnetmeldevnsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgnamemel -Location $locationmel -Name $vnetmeldevnsgname -SecurityRules $nsgruleallowrdp,$nsgruleallowhttp,$nsgruleallowssh
#Assign the NSG to the SNMELDEV Subnet
$vnetmeldevsn = Set-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $vnetmeldevsnAP -Name $vnetmeldevsnname -VirtualNetwork $vnetmeldev -NetworkSecurityGroup $vnetmeldevnsg | Set-AzureRmVirtualNetwork

#Create an NSG for VNETSYDPROD
#Set the variables
$vnetsydprodsnname = "SNSYDPROD"
$vnetsydprodsnAP = "14.0.0.0/25"
$vnetsydprod = Get-AzureRmVirtualNetwork -Name $vnetsydprodname  -ResourceGroupName $rgnamesyd
$vnetsydprodnsgname = "VNETSYDPRODNSG"

#Create the NSG
$vnetsydprodnsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgnamesyd -Location $locationsyd -Name $vnetsydprodnsgname -SecurityRules $nsgruleallowrdp,$nsgruleallowhttp,$nsgruleallowssh
#Assign the NSG to the SNMELDEV Subnet
$vnetsydprodsn = Set-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $vnetsydprodsnAP -Name $vnetsydprodsnname -VirtualNetwork $vnetsydprod -NetworkSecurityGroup $vnetsydprodnsg | Set-AzureRmVirtualNetwork

```

Jump into the portal and you shold now see a new NSG - Network Security Group has been created for each Subnet. drill into the NSG rule and have a look at the inbound and outbound security rules. Note that we can add an NSG to a Subnet or a Network interface and they are cumulative.

# Optional Step
# LAB Create a Gateway

If we wanted tp connect our VNET back to an on-premises environment we could do that by creatning a GatewaySubnet and then creating one of three options.
- Point to Site VPN
- Site to Site VPN 
- EXPRESSROUTE Circuit 

In this step we are going to create a Gateway to our Melbourne VNET.

Copy and paste the following code to Cloud Shell

```
##########
##Step 6##
##########

#Set Networking Variables for Melbourne Production VNET#
$locationmel = "australiasoutheast"
$rgnamemel = "RGMELCONTOSO"

$vnetmelprodname = "VNETMELPROD"
$vnetmelprodpipname = "VNETMELPRODPIP"
$vnetmelprodsngwname = "GatewaySubnet"
$vnetmelprodgwipconfigname = "VNETMELPRODGWIPCONFIG"
$vnetmelprodgwname = "VNETMELPRODGW"

#Get the Virtual Network
$vnetmelprod = Get-AzureRmVirtualNetwork -Name $vnetmelprodname -ResourceGroupName $rgnamemel


$vnetmelprodsngwpip = New-AzureRMPublicIpAddress -Name $vnetmelprodpipname -ResourceGroupName $rgnamemel -Location $locationmel -AllocationMethod Dynamic

#Get the Virtual Network
$vnetmelprod = Get-AzureRmVirtualNetwork -Name $vnetmelprodname -ResourceGroupName $rgnamemel

##Create a new Gateway for your VNET NOTE that this may take up to 45 minutes to complete##
#Get the Subnet IP configuration and Gateway IP Configuration
$vnetmelprodsngwconfig = Get-AzureRmVirtualNetworkSubnetConfig -name $vnetmelprodsngwname -VirtualNetwork $vnetmelprod
$vnetmelprodgwipconfig = New-AzureRMVirtualNetworkGatewayIpConfig -Name $vnetmelprodgwipconfigname -SubnetId $vnetmelprodsngwconfig.Id -PublicIpAddressId $vnetmelprodsngwpip.Id

#Create the Virtual Network Gateway
$vnetmelprodgw = New-AzureRmVirtualNetworkGateway -Name $vnetmelprodgwname -ResourceGroupName $rgnamemel -Location $locationmel -IpConfigurations $vnetmelprodgwipconfig  -GatewayType "Vpn" -VpnType "RouteBased" -GatewaySku "VpnGw1"



```

You should now see a Gateway inside your Resource Group.

Further Reading : https://docs.microsoft.com/en-us/azure/vpn-gateway/

## LAB Create a VM

Now that we have created the base structure for our network. Let's add a few Virtual Machines. We are going to add a VM in each of the VNET's.

Since each VM may take between 7 to 10 minutes we will need to split each one in seperate Cloud Shell sessions to avoid our 20 minute timeout. You can open multiple Cloud Shell sessions n seperate tabs if you wish to speed up the process.

Copy and past the following code to craete VMMELPROD
```
##########
##Step 7##
##########

#######################
##Create VM VMMELPROD##
#######################

# Variables for common values
$locationmel = "australiasoutheast"
$locationsyd = "australiaeast"
$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"
$vmnamesydprod = "VMSYDPROD"
$vmnamemelprod = "VMMELPROD" 
$vmnamemeldev = "VMMELDEV" 
$vmsydprodpipdns = "$($vmnamesydprod)$(Get-Random)"
$vmmelprodpipdns = "$($vmnamemelprod)$(Get-Random)"
$vmmeldevpipdns = "$($vmnamemeldev)$(Get-Random)"
$vmsydprodnicname = "VMSYDPRODNIC"
$vmmelprodnicname = "VMMELPRODNIC"
$vmmeldevnicname = "VMMELDEVNIC"
$vnetmeldevname = "VNETMELDEV"
$vnetmelprodname = "VNETMELPROD"
$vnetsydprodname =  "VNETSYDPROD"
$vnetmelprod = Get-AzureRmVirtualNetwork -Name $vnetmelprodname  -ResourceGroupName $rgnamemel
$vnetmeldev = Get-AzureRmVirtualNetwork -Name $vnetmeldevname  -ResourceGroupName $rgnamemel
$vnetsydprod = Get-AzureRmVirtualNetwork -Name $vnetsydprodname  -ResourceGroupName $rgnamesyd
$samelname = (Get-AzureRmStorageAccount -ResourceGroupName $rgnamemel).StorageAccountName
$sasydname = (Get-AzureRmStorageAccount -ResourceGroupName $rgnamesyd).StorageAccountName

$UserName = 'contosoadmin' 
$Password = 'P@ssw0rd2018'

# Create user object
$StrPass = ConvertTo-SecureString -String $Password -AsPlainText -Force 
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($UserName, $StrPass)

# Create a VM in VNETMELPROD

# Create a public IP address and specify a DNS name
$vmmelprodpip = New-AzureRmPublicIpAddress -ResourceGroupName $rgnamemel -Location $locationmel `
  -Name $vmmelprodpipdns -AllocationMethod Static -IdleTimeoutInMinutes 4


# Create a virtual network card and associate with public IP address and NSG
$vmmelprodnic = New-AzureRmNetworkInterface -Name $vmmelprodnicname -ResourceGroupName $rgnamemel -Location $locationmel `
  -SubnetId $vnetmelprod.Subnets[0].Id -PublicIpAddressId $vmmelprodpip.Id

# Create a virtual machine configuration
$vmmelprodconfig = New-AzureRmVMConfig -VMName $vmnamemelprod -VMSize Standard_D1_v2 | `
Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmnamemelprod -Credential $cred | `
Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `
Add-AzureRmVMNetworkInterface -Id $vmmelprodnic.Id
$vmmelprodconfig = Set-AzureRmVMBootDiagnostics -Enable -ResourceGroupName $rgnamemel -VM $vmmelprodconfig -StorageAccountName $samelname

# Create a virtual machine
New-AzureRmVM -ResourceGroupName $rgnamemel -Location $locationmel -VM $vmmelprodconfig


```

Copy and paste the following code to create VMMELDEV

```
##########
##Step 8##
##########

#######################
##Create VM VMMELDEV##
#######################

# Variables for common values
$locationmel = "australiasoutheast"
$locationsyd = "australiaeast"
$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"
$vmnamesydprod = "VMSYDPROD"
$vmnamemelprod = "VMMELPROD" 
$vmnamemeldev = "VMMELDEV" 
$vmsydprodpipdns = "$($vmnamesydprod)$(Get-Random)"
$vmmelprodpipdns = "$($vmnamemelprod)$(Get-Random)"
$vmmeldevpipdns = "$($vmnamemeldev)$(Get-Random)"
$vmsydprodnicname = "VMSYDPRODNIC"
$vmmelprodnicname = "VMMELPRODNIC"
$vmmeldevnicname = "VMMELDEVNIC"
$vnetmeldevname = "VNETMELDEV"
$vnetmelprodname = "VNETMELPROD"
$vnetsydprodname =  "VNETSYDPROD"
$vnetmelprod = Get-AzureRmVirtualNetwork -Name $vnetmelprodname  -ResourceGroupName $rgnamemel
$vnetmeldev = Get-AzureRmVirtualNetwork -Name $vnetmeldevname  -ResourceGroupName $rgnamemel
$vnetsydprod = Get-AzureRmVirtualNetwork -Name $vnetsydprodname  -ResourceGroupName $rgnamesyd
$samelname = (Get-AzureRmStorageAccount -ResourceGroupName $rgnamemel).StorageAccountName
$sasydname = (Get-AzureRmStorageAccount -ResourceGroupName $rgnamesyd).StorageAccountName

$UserName = 'contosoadmin' 
$Password = 'P@ssw0rd2018'

# Create user object
$StrPass = ConvertTo-SecureString -String $Password -AsPlainText -Force 
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($UserName, $StrPass)


# Create a VM in VNETMELDEV

# Create a public IP address and specify a DNS name
$vmmeldevpip = New-AzureRmPublicIpAddress -ResourceGroupName $rgnamemel -Location $locationmel `
  -Name $vmmeldevpipdns -AllocationMethod Static -IdleTimeoutInMinutes 4


# Create a virtual network card and associate with public IP address and NSG
$vmmeldevnic = New-AzureRmNetworkInterface -Name $vmmeldevnicname -ResourceGroupName $rgnamemel -Location $locationmel `
  -SubnetId $vnetmeldev.Subnets[0].Id -PublicIpAddressId $vmmeldevpip.Id

# Create a virtual machine configuration
$vmmeldevconfig = New-AzureRmVMConfig -VMName $vmnamemeldev -VMSize Standard_D1_v2 | `
Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmnamemeldev -Credential $cred | `
Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `
Add-AzureRmVMNetworkInterface -Id $vmmeldevnic.Id
$vmmeldevconfig = Set-AzureRmVMBootDiagnostics -Enable -ResourceGroupName $rgnamemel -VM $vmmeldevconfig -StorageAccountName $samelname

# Create a virtual machine
New-AzureRmVM -ResourceGroupName $rgnamemel -Location $locationmel -VM $vmmeldevconfig


```

Copy and paste the following code to craete VMSYDPROD

```
##########
##Step 9##
##########

#######################
##Create VM VMSYDPROD##
#######################

# Variables for common values
$locationmel = "australiasoutheast"
$locationsyd = "australiaeast"
$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"
$vmnamesydprod = "VMSYDPROD"
$vmnamemelprod = "VMMELPROD" 
$vmnamemeldev = "VMMELDEV" 
$vmsydprodpipdns = "$($vmnamesydprod)$(Get-Random)"
$vmmelprodpipdns = "$($vmnamemelprod)$(Get-Random)"
$vmmeldevpipdns = "$($vmnamemeldev)$(Get-Random)"
$vmsydprodnicname = "VMSYDPRODNIC"
$vmmelprodnicname = "VMMELPRODNIC"
$vmmeldevnicname = "VMMELDEVNIC"
$vnetmeldevname = "VNETMELDEV"
$vnetmelprodname = "VNETMELPROD"
$vnetsydprodname =  "VNETSYDPROD"
$vnetmelprod = Get-AzureRmVirtualNetwork -Name $vnetmelprodname  -ResourceGroupName $rgnamemel
$vnetmeldev = Get-AzureRmVirtualNetwork -Name $vnetmeldevname  -ResourceGroupName $rgnamemel
$vnetsydprod = Get-AzureRmVirtualNetwork -Name $vnetsydprodname  -ResourceGroupName $rgnamesyd
$samelname = (Get-AzureRmStorageAccount -ResourceGroupName $rgnamemel).StorageAccountName
$sasydname = (Get-AzureRmStorageAccount -ResourceGroupName $rgnamesyd).StorageAccountName

$UserName = 'contosoadmin' 
$Password = 'P@ssw0rd2018'

# Create user object
$StrPass = ConvertTo-SecureString -String $Password -AsPlainText -Force 
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($UserName, $StrPass)


# Create a VM in VNETSYDPROD


# Create a public IP address and specify a DNS name
$vmsydpip = New-AzureRmPublicIpAddress -ResourceGroupName $rgnamesyd -Location $locationsyd `
  -Name $vmsydprodpipdns -AllocationMethod Static -IdleTimeoutInMinutes 4


# Create a virtual network card and associate with public IP address and NSG
$vmsydnic = New-AzureRmNetworkInterface -Name $vmsydprodnicname -ResourceGroupName $rgnamesyd -Location $locationsyd `
  -SubnetId $vnetsydprod.Subnets[0].Id -PublicIpAddressId $vmsydpip.Id

# Create a virtual machine configuration
$vmsydconfig = New-AzureRmVMConfig -VMName $vmnamesydprod -VMSize Standard_D1_v2 | `
Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmnamesydprod -Credential $cred | `
Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `
Add-AzureRmVMNetworkInterface -Id $vmsydnic.Id
$vmsydconfig = Set-AzureRmVMBootDiagnostics -Enable -ResourceGroupName $rgnamesyd -VM $vmsydconfig -StorageAccountName $sasydname

# Create a virtual machine
New-AzureRmVM -ResourceGroupName $rgnamesyd -Location $locationsyd -VM $vmsydconfig

```

Further Reading : 
https://docs.microsoft.com/en-us/azure/virtual-machines/windows/

https://docs.microsoft.com/en-us/azure/virtual-machines/linux/


Further reading : https://docs.microsoft.com/en-us/azure/networking/networking-overview

https://docs.microsoft.com/en-us/azure/virtual-network/security-overview

https://docs.microsoft.com/en-au/azure/virtual-network/tutorial-filter-network-traffic

# LAB Create a VM Scale Set 

If we want to build to scale in IAAS we need to look at creating a VM Scale Set. In this lab we wil create two simple VM Scale Set's that will enable IIS and simply configure the Web Site to display the active Instance's hostname.

As before we will create each VM Scale set in seperate Cloud Shell sessions to avoid the Cloud Shell timewout.

Run the following commands to spin up a VM Scale Set in Melbourne.

```
###########
##Step 10##
###########

###################################
##Create VM Scale Set VMSSMELPROD##
###################################

# Variables for common values
$locationmel = "australiasoutheast"
$locationsyd = "australiaeast"
$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"
$vmssnamesydprod = "VMSSSYDPROD"
$vmssnamemelprod = "VMSSMELPROD"  
$lbmelprodname = "LBMELPROD"
$lbsydprodname = "LBSYDPROD"
$vmsssydprodpipdns = "$($vmssnamesydprod)$(Get-Random)"
$vmssmelprodpipdns = "$($vmssnamemelprod)$(Get-Random)"
$vnetmelprodname = "VNETMELPROD"
$vnetsydprodname =  "VNETSYDPROD"
$vnetmelprodsnname = "SNMELPROD"
$vnetsydprodsnname = "SNSYDPROD"
$UserName = 'contosoadmin' 
$Password = 'P@ssw0rd2018'

# Create user object
$StrPass = ConvertTo-SecureString -String $Password -AsPlainText -Force 
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($UserName, $StrPass)

######################################
#Create a VM Scale Set in VNETMELPROD#
######################################

    New-AzureRmVmss `
    -ResourceGroupName $rgnamemel `
    -VMScaleSetName $vmssnamemelprod `
    -Location $locationmel `
    -VirtualNetworkName $vnetmelprodname `
    -SubnetName $vnetmelprodsnname `
    -PublicIpAddressName $vmssmelprodpipdns `
    -LoadBalancerName $lbmelprodname `
    -UpgradePolicyMode "Automatic" `
    -Credential $cred `
    -InstanceCount 2 `
    -VmSize Standard_D1_v2

    $customConfig = @{
      "fileUris" = (,"https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate-iis.ps1");
      "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File automate-iis.ps1"
    }


    # Get information about the scale set
$vmssmel = Get-AzureRmVmss `
-ResourceGroupName $rgnamemel `
-VMScaleSetName $vmssnamemelprod

# Add the Custom Script Extension to install IIS and configure basic website
$vmssmel = Add-AzureRmVmssExtension `
-VirtualMachineScaleSet $vmssmel `
-Name "customScript" `
-Publisher "Microsoft.Compute" `
-Type "CustomScriptExtension" `
-TypeHandlerVersion 1.9 `
-Setting $customConfig

# Update the scale set and apply the Custom Script Extension to the VM instances
Update-AzureRmVmss `
-ResourceGroupName $rgnamemel `
-Name $vmssnamemelprod `
-VirtualMachineScaleSet $vmssmel

#Get the Public IP and connect to it to see the Website
Get-AzureRmPublicIpAddress -ResourceGroupName $rgnamemel -Name $vmssmelprodpipdns | Select IpAddress


```

Run the following commands to spin up a VM Scale Set in Sydney.

```
###########
##Step 11##
###########

###################################
##Create VM Scale Set VMSSSYDPROD##
###################################

# Variables for common values
$locationmel = "australiasoutheast"
$locationsyd = "australiaeast"
$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"
$vmssnamesydprod = "VMSSSYDPROD"
$vmssnamemelprod = "VMSSMELPROD"  
$lbmelprodname = "LBMELPROD"
$lbsydprodname = "LBSYDPROD"
$vmsssydprodpipdns = "$($vmssnamesydprod)$(Get-Random)"
$vmssmelprodpipdns = "$($vmssnamemelprod)$(Get-Random)"
$vnetmelprodname = "VNETMELPROD"
$vnetsydprodname =  "VNETSYDPROD"
$vnetmelprodsnname = "SNMELPROD"
$vnetsydprodsnname = "SNSYDPROD"
$UserName = 'contosoadmin' 
$Password = 'P@ssw0rd2018'

# Create user object
$StrPass = ConvertTo-SecureString -String $Password -AsPlainText -Force 
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($UserName, $StrPass)

######################################
#Create a VM Scale Set in VNETSYDPROD#
######################################

New-AzureRmVmss `
-ResourceGroupName $rgnamesyd `
-VMScaleSetName $vmssnamesydprod `
-Location $locationsyd `
-VirtualNetworkName $vnetsydprodname `
-SubnetName $vnetsydprodsnname `
-PublicIpAddressName $vmsssydprodpipdns `
-LoadBalancerName $lbsydprodname `
-UpgradePolicyMode "Automatic" `
-Credential $cred `
-InstanceCount 2 `
-VmSize Standard_D1_v2


$customConfig = @{
  "fileUris" = (,"https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate-iis.ps1");
  "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File automate-iis.ps1"
}


# Get information about the scale set
$vmsssyd = Get-AzureRmVmss `
-ResourceGroupName $rgnamesyd `
-VMScaleSetName $vmssnamesydprod

# Add the Custom Script Extension to install IIS and configure basic website
$vmsssyd = Add-AzureRmVmssExtension `
-VirtualMachineScaleSet $vmsssyd `
-Name "customScript" `
-Publisher "Microsoft.Compute" `
-Type "CustomScriptExtension" `
-TypeHandlerVersion 1.9 `
-Setting $customConfig

# Update the scale set and apply the Custom Script Extension to the VM instances
Update-AzureRmVmss `
-ResourceGroupName $rgnamesyd `
-Name $vmssnamesydprod `
-VirtualMachineScaleSet $vmsssyd

#Get the Public IP and connect to it to see the Website
Get-AzureRmPublicIpAddress -ResourceGroupName $rgnamesyd -Name $vmsssydprodpipdns | Select IpAddress

```

At the end of each command you will see the Public IP address listed. 

<figure>
        <img src="img/lbpip.jpg" alt="Load Balancer Public IP" />
        <figcaption>Load Balancer Public IP</figcaption>
</figure>

In a browser session type in the public IP and you should see it return the Web page of the specific  host on the VM Scale Set you are connected to.

<figure>
        <img src="img/lboutput.jpg" alt="Load Balancer Output" />
        <figcaption>Load Balancer Output</figcaption>
</figure>


Further Reading : https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview

https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-overview

# LAB Add a Traffic Manager Profile

One way we can add Global DNS load balancing is through a Traffic Manager Profile. Let's create a new Profile and add the the two VM Scale Set Public IP's as Endpoint's of that Traffic Manager Profile.

```
###########
##Step 12##
###########

###############################
#Add a Traffic Manager Profile#
###############################

$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"
$vmssnamesydprod = "VMSSSYDPROD"
$vmssnamemelprod = "VMSSMELPROD"  
$tmpname = "TMCONTOSO$(Get-Random)"

## Get the Sydney VMSS Public IP details

$vmsssydprodpipdns = (Get-AzureRmPublicIpAddress -ResourceGroupName $rgnamesyd | Where-Object {$_.Name -like "VMSSSYDPROD*"}).Name
$vmsssydprodpipdnsid = (Get-AzureRmPublicIpAddress -ResourceGroupName $rgnamesyd -Name $vmsssydprodpipdns).Id
## Get the Melbourne VMSS Public IP details
$vmssmelprodpipdns = (Get-AzureRmPublicIpAddress -ResourceGroupName $rgnamemel | Where-Object {$_.Name -like "VMSSMELPROD*"}).Name
$vmssmelprodpipdnsid = (Get-AzureRmPublicIpAddress -ResourceGroupName $rgnamemel -Name $vmssmelprodpipdns).Id


$tmglobalprod = New-AzureRmTrafficManagerProfile -MonitorPort 80 -MonitorProtocol HTTP -Name $tmpname -RelativeDnsName $tmpname -ResourceGroupName $rgnamemel -TrafficRoutingMethod Performance -Ttl 30 -ProfileStatus Enabled -MonitorPath "/"

$vmssnamesydprodendpoint = New-AzureRmTrafficManagerEndpoint -Name $vmssnamesydprod -ProfileName $tmglobalprod.Name -ResourceGroupName $rgnamemel -Type AzureEndpoints -TargetResourceId $vmsssydprodpipdnsid -EndpointStatus Enabled
$vmssnamemelprodendpoint = New-AzureRmTrafficManagerEndpoint -Name $vmssnamemelprod -ProfileName $tmglobalprod.Name -ResourceGroupName $rgnamemel -Type AzureEndpoints -TargetResourceId $vmssmelprodpipdnsid -EndpointStatus Enabled

$tmpdnsname = "http://$((Get-AzureRmTrafficManagerProfile).RelativeDnsName).trafficmanager.net"

$tmpdnsname

```

Once the Traffic Manager Profile has been deployed the final output will show you the DNS name of the Traffic Manager profile


<figure>
        <img src="img/tmpdns.jpg" alt="Traffic Manager Profile DNS" />
        <figcaption>Traffic Manager Profile DNS</figcaption>
</figure>

Copy that DNS name and paste it into a browser to see your local endpoint.

<figure>
        <img src="img/tmpoutput.jpg" alt="Traffic Manager Profile Output" />
        <figcaption>Traffic Manager Profile Output</figcaption>
</figure>


# Challenge
* Set a Policy
* Set a Resource Lock
* Apply Tags
* Attempt to connect from one VM to another in a Separate VNET (You will need RDP or SSH access for this challenge)
* Scale your VMScaleSet


Further reading : https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview 


[Further Labs](./Labs2.MD)