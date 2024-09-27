param webfrontName string
param apibackendName string
param apimName string
param appInsightsConnectoinString string

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
}  

module webfrontSettings 'appsettings.bicep' = {
  name: 'webfrontSettings'
  params: {
    appsvcName: webfrontName
    currentAppSettings: webfrontRef::appsettings.properties
    appSettings: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectoinString
      BACKEND_API_ENDPOINT: 'http://${apimName}.azure-api.net'
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
    appsvcName: webfrontName
    currentAppSettings: webfrontRef::appsettings.properties
    appSettings: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectoinString
    }
  }
}


