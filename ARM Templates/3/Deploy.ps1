##Not Required if you are in an Azure Cloud Shell session##
#Login-AzureRmAccount
##Not Required if you are in an Azure Cloud Shell session##
#$Subscriptionname = "Visual Studio Ultimate with MSDN"
#Set-AzureRmContext -Subscription $Subscriptionname

##Start here if you are in an Azure Cloud Shell session##
#List locations - Choose the location for the Resource Group#
#(Get-Azurermlocation).location

try {
    Get-AzureRmSubscription -ErrorAction STOP
}
catch {
    Write-Host "Login to Azure Account" -ForegroundColor Green
    Login-AzureRmAccount
}


#setting variables for the storage account#
$locationmel = "australiasoutheast"
$locationsyd = "australiaeast"
$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"

$MelStorageAccountName = "samel$(Get-Random)"
$SydStorageAccountName = "sasyd$(Get-Random)"
$VMMelProdIpDns = "VNETMELPROD$(Get-Random)"
$VMSydProdIpDns = "VNETSYDPROD$(Get-Random)"
$VMMelDevIpDns = "VNETMELDEV$(Get-Random)"

$UserName = 'contosoadmin'

#Creating a new resource group#
New-AzureRmResourceGroup -Name $rgnamemel -Location $locationmel
New-AzureRmResourceGroup -Name $rgnamesyd -Location $locationsyd

$MELParams = @{
    VNETAddressSpace           = "12.0.0.0/24"
    VNETProdName               = "VNETMELPROD"
    VNETProdSubnetName         = "SNMELPROD"
    VNETProdSubnetAddressSpace = "12.0.0.0/25"
    VMProdIpDns                = $VMMelProdIpDns
    VMLoadBalancerName         = "LBMELPROD"
    InstanceCount              = 2
    VMSSName                   = "VMSSMELPROD"
    UserName                   = $UserName
    Password                   = 'P@ssw0rd2018'
    VMNameProd                 = "VMMELPROD"
    VMProdNicName              = "VMMELPRODNIC"
    ProdNSGName                = "VNETMELPRODNSG"
}

$SYDParams = @{
    VNETAddressSpace           = "14.0.0.0/24"
    VNETProdName               = "VNETSYDPROD"
    VNETProdSubnetName         = "SNSYDPROD"
    VNETProdSubnetAddressSpace = "14.0.0.0/25"
    VMProdIpDns                = $VMSydProdIpDns
    VMLoadBalancerName         = "LBSYDPROD"
    InstanceCount              = 2
    VMSSName                   = "VMSSSYDPROD"
    UserName                   = $UserName
    Password                   = 'P@ssw0rd2018'
    VMNameProd                 = "VMSYDPROD"
    VMProdNicName              = "VMSYDPRODNIC"
    ProdNSGName                = "VNETSYDPRODNSG"
}

$TrafficManagerParams = @{
    TrafficManagerName = "TMVMSSMel"
    VMMelProdIpDns     = $VMMelProdIpDns
    VMSydProdIpDns     = $VMSydProdIpDns
}

New-AzureRMResourceGroupDeployment -ResourceGroupName $rgnamemel -TemplateFile .\3\contosoObjects.json -TemplateParameterObject $MELParams -Verbose
New-AzureRMResourceGroupDeployment -ResourceGroupName $rgnamesyd -TemplateFile .\3\contosoObjects.json -TemplateParameterObject $SYDParams -Verbose 
New-AzureRMResourceGroupDeployment -ResourceGroupName $rgnamemel -TemplateFile .\3\trafficmanager.json -TemplateParameterObject $TrafficManagerParams -Verbose



