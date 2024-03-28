metadata name = 'ExpressRoute Authorization Key'
metadata description = 'Create the ExpressRoute Authorization Keys for ExpressRoute Gateway connections.'

@description('Required. The name of the AVS private cloud.')
param privateCloudName string

@description('The name of the ExpressRoute Authorization Key.')
param authKeyName string

resource privateCloud 'Microsoft.AVS/privateClouds@2022-05-01' existing = {
  name: privateCloudName
}

resource authKey 'Microsoft.AVS/privateClouds/authorizations@2022-05-01' = {
  name: authKeyName
  parent: privateCloud
}

@description('The Id of the ExpressRoute Authorization Key.')
output authKeyId string = authKey.properties.expressRouteAuthorizationId

@description('The ExpressRoute Authorization Key.')
output authKey string = authKey.properties.expressRouteAuthorizationKey
