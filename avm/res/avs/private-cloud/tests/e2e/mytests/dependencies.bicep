@description('Optional. The location to deploy to.')
param location string = resourceGroup().location

@description('Required. The name of the Managed Identity to create.')
param managedIdentityName string

@description('Required. The name of the NAT Gateway Public IP Address to create.')
param natGatewayPublicIPName string

@description('Required. The name of the NAT Gateway to create.')
param natGatewayName string

@description('Required. The name of the Gateway Virtual Network to create.')
param gatewayVNetName string

@description('Required. The name of the Gateway Public IP Address to create.')
param gatewayPublicIPName string

@description('Required. The name of the Gateway to create.')
param gatewayName string

@description('Required. The name of the Key Vault to create.')
param keyVaultName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

module natGatewayPublicIP '../../../../../network/public-ip-address/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-natGatewayPublicIP'
  params: {
    name: natGatewayPublicIPName
    location: location
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
  }
}

resource natGateway 'Microsoft.Network/natGateways@2023-09-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIpAddresses: [
      {
        id: natGatewayPublicIP.outputs.resourceId
      }
    ]
  }
  dependsOn: [
    natGatewayPublicIP
  ]
}

module gatewayVNet '../../../../../network/virtual-network/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-gatewayVNet'
  params: {
    name: gatewayVNetName
    location: location
    addressPrefixes: [
      '10.100.0.0/16'
    ]
    subnets: [
      {
        addressPrefix: '10.100.0.0/24'
        name: 'GatewaySubnet'
      }
      {
        addressPrefix: '10.100.1.0/24'
        name: 'VMSubnet'
        natGateway: natGateway.id
      }
      {
        addressPrefix: '10.100.2.0/24'
        name: 'AzureBastionSubnet'
      }
    ]
  }
}

module gatewayPublicIP '../../../../../network/public-ip-address/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-gatewayPublicIP'
  params: {
    name: gatewayPublicIPName
    location: location
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
  }
}

resource gateway 'Microsoft.Network/virtualnetworkgateways@2021-02-01' = {
  name: gatewayName
  location: location
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gatewayVNet.outputs.subnetResourceIds[0]
          }
          publicIPAddress: {
            id: gatewayPublicIP.outputs.resourceId
          }
        }
        name: 'gwIPConfig'
      }
    ]
    gatewayType: 'ExpressRoute'
    sku: {
      name: 'ErGw1AZ'
      tier: 'ErGw1AZ'
    }
  }
  dependsOn: [
    gatewayVNet
    gatewayPublicIP
  ]
}

module keyVault '../../../../../key-vault/vault/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-keyVault'
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Administrator'
        principalId: managedIdentity.properties.principalId
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

@description('The principal ID of the created Managed Identity.')
output managedIdentityPrincipalId string = managedIdentity.properties.principalId

@description('The resource ID of the created NAT Gateway.')
output natGatewayResourceId string = natGateway.id
