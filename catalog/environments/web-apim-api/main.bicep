param region string

var postfix = toLower(uniqueString(subscription().id, resourceGroup().name, region))
var webfrontName = 'web-frontend-${postfix}'
var apibackendName = 'web-backend-${postfix}'
var logAnalyticsName = 'laws-${postfix}'
var appInsightsName = 'ai-${postfix}'
var apimName = 'apim-${postfix}'
var straccName = 'str${postfix}'

module monitor 'monitor.bicep' = {
  name: 'monitor'
  params: {
    region: region
    logAnalyticsName: logAnalyticsName
    appInsightsName: appInsightsName
  }
}

module webfront 'appservice.bicep' = {
  name: 'webfront'
  params: {
    region: region
    appSvcName: webfrontName
  }
}

module apibackend 'appservice.bicep' = {
  name: 'apibackend'
  params: {
    region: region
    appSvcName: apibackendName
  }
}

module apiman 'apiman.bicep' = {
  name: 'apiman'
  dependsOn: [
    monitor
  ]
  params: {
    region: region
    apimName: apimName
    logAnalyticsName: logAnalyticsName
    appInsightsName: appInsightsName
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: straccName
  location: region
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }

  resource queueSvc 'queueServices' = {
    name: 'default'
    resource queue 'queues' = {
      name: 'queue1'
    }
  }
  resource blobSvc 'blobServices' = {
    name: 'default'
    resource container 'containers' = {
      name: 'container1'
    }
  }
}

module relation 'relation.bicep' = {
  name: 'relation'
  dependsOn: [monitor, webfront, apibackend, apiman, storage]
  params: {
    webfrontName: webfrontName
    apibackendName: apibackendName
    apimName: apimName
    appInsightsConnectoinString: monitor.outputs.appInsightsConnectionString
    storageAccountName: straccName
  }
}
