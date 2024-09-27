param region string
param appSvcName string

var appSvcPlanName = 'svrfrm-${appSvcName}'

resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appSvcPlanName
  location: region
  sku: {
    name: 'S1'
    capacity: 1
  }
}

resource web 'Microsoft.Web/sites@2022-09-01' = {
  name: appSvcName
  location: region
  properties:{
    serverFarmId: asp.id
    clientAffinityEnabled: false
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      ftpsState: 'Disabled'
      use32BitWorkerProcess: false
    }
  }
}

resource metadata 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'metadata'
  parent: web
  properties: {
    CURRENT_STACK: 'dotnet'
  }
}

output endpoint string = 'https://${web.properties.defaultHostName}'
