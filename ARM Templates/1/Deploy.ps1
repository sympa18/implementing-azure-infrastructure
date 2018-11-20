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
    StorageAccountName          = $MelStorageAccountName 
    VNETAddressSpace            = "12.0.0.0/24"
    VNETProdName                = "VNETMELPROD"
    VNETProdSubnetName          = "SNMELPROD"
    VNETProdSubnetAddressSpace  = "12.0.0.0/25"
    VNETProdGatewayAddressSpace = "12.0.0.224/27"
    VNETDevName                 = "VNETMELDEV"
    VNETDevAddressSpace         = "13.0.0.0/24"
    VNETDevSubnetName           = "SNMELDEV"
    VNETDevSubnetAddressSpace   = "13.0.0.0/25"
    DeployDevNetwork            = "True"
    ProdNSGName                 = "VNETMELPRODNSG"
    DevNSGName                  = "VNETMELDEVNSG"
    DeployMelPeering            = "True"
    VMProdNicName               = "VMMELPRODNIC"
    VMProdIpDns                 = $VMMelProdIpDns
    VMDevIpDns                  = $VMMelDevIpDns
    VMDevNicName                = "VMMELDEVNIC"
    UserName                    = $UserName
    Password                    = 'P@ssw0rd2018'
    VMNameProd                  = "VMMELPROD"
    VMNameDev                   = "VMMELDEV"
}

$SYDParams = @{
    StorageAccountName          = $SydStorageAccountName
    VNETAddressSpace            = "14.0.0.0/24"
    VNETProdName                = "VNETSYDPROD"
    VNETProdSubnetName          = "SNSYDPROD"
    VNETProdSubnetAddressSpace  = "14.0.0.0/25"
    VNETProdGatewayAddressSpace = "14.0.0.224/27"
    ProdNSGName                 = "VNETSYDPRODNSG"
    DeploySydPeering            = "True"
    VMProdNicName               = "VMSYDPRODNIC"
    VMProdIpDns                 = $VMSYDProdIpDns
    UserName                    = $UserName
    Password                    = 'P@ssw0rd2018'
    VMNameProd                  = "VMSYDPROD"
}

New-AzureRMResourceGroupDeployment -ResourceGroupName $rgnamemel -TemplateFile .\1\contosoObjects.json -TemplateParameterObject $MELParams -Verbose
New-AzureRMResourceGroupDeployment -ResourceGroupName $rgnamesyd -TemplateFile .\1\contosoObjects.json -TemplateParameterObject $SYDParams -Verbose 




