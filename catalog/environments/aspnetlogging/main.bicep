
param region string

var postfix = toLower(uniqueString(subscription().id, resourceGroup().name, region))
var apimName = 'apim-${postfix}'

resource apimanRef 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: apimName
}


output temp string = apimanRef.properties.gatewayUrl
