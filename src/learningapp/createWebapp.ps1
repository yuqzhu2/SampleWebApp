$resourceGroupName = "az204-webapp"
$location = "australiaeast"
$webAppName = "az204-webapp-$(Get-Random)"
$planName = "az204-webapp-plan"

New-AzAppServicePlan -Location $location `
    -Name $planName `
    -ResourceGroupName $resourceGroupName `
    -Tier "Free"

    