param appsvcName string
param appSettings object
param currentAppSettings object

resource appsvc 'Microsoft.Web/sites@2022-03-01' existing = {
  name: appsvcName
}

resource siteconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appsvc
  name: 'appsettings'
  properties: union(currentAppSettings, appSettings)
}
