$rgnamemel = "RGMELCONTOSO"
$rgnamesyd = "RGSYDCONTOSO"

Remove-AzureRMResourceGroup -ResourceGroupName $rgnamemel -Force -AsJob
Remove-AzureRMResourceGroup -ResourceGroupName $rgnamesyd -Force -AsJob

