metadata name = 'AVS Private Cloud Authorizations'
metadata description = 'This module creates a connection between AVS SDDC and a vNet, when Networking Connectivity is enabled.'
metadata owner = 'Azure/module-maintainers'

@description('Required. The name of the AVS private cloud.')
param privateCloudName string

@description('Required. The name of the customer ExpressRoute Virtual Network Gateway of the Hub vNet.')
param gatewayName string

@description('Required. The name of the Authorization Key.')
param authKeyName string

@description('Required. The name of the connection.')
param connectionName string

@description('Required. Location of the resources.')
param location string

resource privateCloud 'Microsoft.AVS/privateClouds@2023-03-01' existing = {
  name: privateCloudName
}

resource gateway 'Microsoft.Network/virtualNetworkGateways@2023-09-01' existing = {
  name: gatewayName
}

resource expressRouteAuthKey 'Microsoft.AVS/privateClouds/authorizations@2023-03-01' = {
  name: authKeyName
  parent: privateCloud
}

resource connection 'Microsoft.Network/connections@2023-09-01' = {
  name: connectionName
  location: location
  properties: {
    connectionType: 'ExpressRoute'
    routingWeight: 0
    virtualNetworkGateway1: {
      id: gateway.id
      properties: {}
    }
    peer: {
      id: privateCloud.properties.circuit.expressRouteID
    }
    authorizationKey: expressRouteAuthKey.properties.expressRouteAuthorizationKey
  }
}

@description('The Authorization Key.')
output expressRouteAuthKey string = expressRouteAuthKey.properties.expressRouteAuthorizationKey

@description('The Connection ID.')
output connectionId string = connection.id
