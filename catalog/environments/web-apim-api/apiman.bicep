param region string
param apimName string
param appInsightsName string
param logAnalyticsName string

param apimPublisher string = 'Contoso'
param apimPublisherEmail string = 'contoso@example.com'


resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsName
}

resource appinsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource apiman 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: apimName
  location: region
  sku: {
    name: 'Consumption'
    capacity: 0
  }
  properties: {
    publisherName: apimPublisher
    publisherEmail: apimPublisherEmail
  }
  identity: { type: 'SystemAssigned' }

  resource ailogger 'loggers' = {
    name: '${appInsightsName}-logger'
    properties: {
      loggerType: 'applicationInsights'
      resourceId: appinsights.id
      credentials: {
        instrumentationKey: appinsights.properties.InstrumentationKey
      }
    }
  }

  resource diagnostics 'diagnostics' = {
    name: 'applicationinsights'
    properties: {
      loggerId: ailogger.id
      alwaysLog: 'allErrors'
      logClientIp: true
      verbosity: 'verbose'
      }
  }
}

resource apimDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${apiman.name}-diag'
  scope: apiman
  properties: {
    workspaceId: logAnalytics.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'GatewayLogs'
        enabled: true
      }
      {
        category: 'WebSocketConnectionLogs'
        enabled: true
      }
    ]
    metrics: [
      {
         category: 'AllMetrics'
         enabled: true
      }
    ]
  }
}
