param region string

var postfix = toLower(uniqueString(subscription().id, resourceGroup().name, region))
var webfrontName = 'web-frontend-${postfix}'
var apibackendName = 'web-backend-${postfix}'
var logAnalyticsName = 'laws-${postfix}'
var appInsightsName = 'ai-${postfix}'
var apimName = 'apim-${postfix}'


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

module relation 'relation.bicep' = {
  name: 'relation'
  dependsOn: [monitor, webfront, apibackend, apiman]
  params: {
    webfrontName: webfrontName
    apibackendName: apibackendName
    apimName: apimName
    appInsightsConnectoinString: monitor.outputs.appInsightsConnectionString
  }
}
