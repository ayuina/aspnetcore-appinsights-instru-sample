param webfrontName string
param apibackendName string
param apimName string
param appInsightsConnectoinString string
param storageAccountName string

resource webfrontRef 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webfrontName

  resource appsettings 'config' existing = {
    name: 'appsettings'
  }
}

resource apibackendRef 'Microsoft.Web/sites@2022-03-01' existing = {
  name: apibackendName

  resource appsettings 'config' existing = {
    name: 'appsettings'
  }
}

resource apimanRef 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: apimName

  resource frontSubsc 'subscriptions' = {
    name: 'frontSubsc'
    properties: {
      displayName: 'subscription for web front'
      scope: '${apimanRef.id}/apis'
    }
  }
}  

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}


module webfrontSettings 'appsettings.bicep' = {
  name: 'webfrontSettings'
  params: {
    appsvcName: webfrontName
    currentAppSettings: webfrontRef::appsettings.properties
    appSettings: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectoinString
      'Logging:ApplicationInsights:LogLevel:Default': 'Information'
      'Logging:ApplicationInsights:LogLevel:Microsoft.AspNetCore': 'Information'
      BACKEND_API_ENDPOINT: apimanRef.properties.gatewayUrl
      //BACKEND_API_KEY: listSecrets(apimanRef::frontSubsc.id, '2023-09-01-preview').primaryKey
      BACKEND_API_KEY: apimanRef::frontSubsc.listSecrets().primaryKey
      BACKEND_API_AUTH_HEADER_NAME: 'Ocp-Apim-Subscription-Key'
      STORAGE_CONNECTION_STRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
    }
  }
}

resource apimbackends 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apimanRef
  name: 'webapi-backend'
  properties: {
    title: 'webapi-backend'
    type: 'Single'
    protocol: 'http'
    url: 'https://${apibackendRef.properties.defaultHostName}'
  }
}

module apibackendSettings 'appsettings.bicep' = {
  name: 'apibackendSettings'
  params: {
    appsvcName: apibackendName
    currentAppSettings: apibackendRef::appsettings.properties
    appSettings: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectoinString
      'Logging:ApplicationInsights:LogLevel:Default': 'Information'
      'Logging:ApplicationInsights:LogLevel:Microsoft.AspNetCore': 'Information'
      STORAGE_CONNECTION_STRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
    }
  }
}


