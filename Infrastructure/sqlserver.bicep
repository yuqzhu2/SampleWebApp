
@description('Base name for the SQL server and database resources.')
param sqlDatabaseName string

@description('The list of IP addresses that are allowed to access the SQL server.')
@minLength(1)
param developerIps array

@secure()
@description('The administrator login name for the SQL server.')
param adminLogin string

@secure()
@description('The administrator login password for the SQL server.')
param adminLoginPassword string

resource mySqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: '${sqlDatabaseName}Server${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminLoginPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource mySqlFirewallRule 'Microsoft.Sql/servers/firewallRules@2021-02-01-preview' = [for ip in developerIps: {
  name: 'AllowDeveloperIp-${ip}'
  parent: mySqlServer
  properties: {
    startIpAddress: ip
    endIpAddress: ip
  }
}]

resource mySqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  name: sqlDatabaseName
  parent: mySqlServer
  location: resourceGroup().location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: '2147483648' // 2 GB
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

output sqlServerName string = mySqlServer.name
output sqlServerId string = mySqlServer.id
output sqlDatabaseName string = mySqlDatabase.name
output sqlDatabaseId string = mySqlDatabase.id
output sqlServerEndpoint string = 'https://${mySqlServer.name}${environment().suffixes.sqlServerHostname}'
output sqlServerAdminLogin string = mySqlServer.properties.administratorLogin
