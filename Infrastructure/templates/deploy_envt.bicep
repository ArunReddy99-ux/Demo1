param location string = resourceGroup().location
param storageNamePrefix string
param acr_name string = 'techsckoolacr'
param asb_name string = 'techsckoolasb'

@description('Name of the App Service Plan')
param hostingPlanName string = 'techsckool-asp'

@description('SKU for the App Service Plan')
param hostingPlanSku string = 'P1v2'

@description('Number of workers for the App Service Plan')
param numberOfWorkers int = 1

@description('Name of the Web App')
param webAppName string = 'techsckool-webapp'

@description('Linux FX Version for .NET 8')
param linuxFxVersion string = 'DOTNET|8.0'

var stgacc_name = '${storageNamePrefix}${uniqueString(resourceGroup().id)}'

resource storage_account 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: stgacc_name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource container_registry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acr_name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource asb 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: asb_name
  location: location
}

resource app_service_plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: hostingPlanSku
    tier: 'PremiumV2'
    size: hostingPlanSku
    capacity: numberOfWorkers
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource web_app 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: app_service_plan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
    }
    httpsOnly: true
  }
}

output webAppUrl string = web_app.properties.defaultHostName
