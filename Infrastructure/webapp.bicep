
resource myAppServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'yzServicePlan${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
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
