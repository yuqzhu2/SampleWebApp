
@description('The name of the resource group where the App Service Plan and Web App will be created.')
type planos = 'Windows' | 'Linux'

@description('The operating system for the App Service Plan. Choose "Windows" or "Linux", default to "Windows".')
param servicePlanOs planos = 'Windows'

@description('The SKU name for the App Service Plan. Default is S1.')
@allowed([
  'F1' // Free
  'D1' // Shared
  'B1' // Basic
  'B2'
  'B3'
  'S1' // Standard
  'S2'
  'S3'
  'P0v3' // Premium v3
  'P1v3' 
  'P2v3'
  'P3v3'
])
@defaultValue('P0v3')
param skuName string = 'P0v3' // Default SKU for the App Service Plan

resource myAppServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'yzServicePlan${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  kind: servicePlanOs
  sku: {
    name: 'S1'
    capacity: 1
  }
}

resource myWebApp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'yzWebApp${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  kind: 'app'
  properties: {
    serverFarmId: myAppServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      use32BitWorkerProcess: false
      // Windows-specific configurations
      // If servicePlanOs is 'Windows', set netFrameworkVersion and metadata
      netFrameworkVersion: (servicePlanOs == 'Windows') ? 'v8.0' : null // or 'v6.0', 'v4.8', etc.
      metadata: servicePlanOs == 'Windows' ? [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ] : null
      // Linux-specific configurations
      // If servicePlanOs is 'Linux', set linuxFxVersion
      linuxFxVersion: (servicePlanOs == 'Linux') ? 'dotnet:8' : null
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '14.17'
        }
      ]
    }
  }
}

output appServicePlanId string = myAppServicePlan.id
output webAppId string = myWebApp.id
output webAppUrl string = 'https://${myWebApp.name}.azurewebsites.net'
output webAppName string = myWebApp.name
output appServicePlanName string = myAppServicePlan.name
