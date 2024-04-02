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

@description('Required. The name of the Bastion Public IP Address to create.')
param bastionPublicIPName string

@description('Required. The name of the Bastion Host to create.')
param bastionName string

@description('Required. The name of the Key Vault to create.')
param keyVaultName string

@description('Required. The name of the ANF Account to create.')
param anfAccountName string

@description('Required. The name of the ANF Pool to create.')
param anfPoolName string

@description('Required. The name of the ANF Volume to create.')
param anfVolumeName string

@description('Required. The name of the Jump VM NIC to create.')
param jumpVMNICName string

@description('Required. The name of the Jump VM to create.')
param jumpVMName string

@description('Required. The Administrator of the Jump VM.')
param jumpVMAdminUsername string

@description('Required. The Admin password of the Jump VM.')
@secure()
param jumpVMAdminPassword string

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
      {
        addressPrefix: '10.100.3.0/24'
        name: 'ANFSubnet'
        delegations: [
          {
            name: 'Microsoft.NetApp/volumes'
            properties: {
              serviceName: 'Microsoft.NetApp/volumes'
              actions: [
                'Microsoft.Network/networkinterfaces/*'
                'Microsoft.Network/virtualNetworks/subnets/join/action'
              ]
            }
          }
        ]
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

module bastionPublicIP '../../../../../network/public-ip-address/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-bastionPublicIP'
  params: {
    name: bastionPublicIPName
    location: location
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
  }
}

module bastionHost '../../../../../network/bastion-host/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-bastionHost'
  params: {
    name: bastionName
    location: location
    vNetId: gatewayVNet.outputs.resourceId
    bastionSubnetPublicIpResourceId: bastionPublicIP.outputs.resourceId
    skuName: 'Basic'
  }
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
    keys: [
      {
        name: 'cmk-disk-key'
        kty: 'RSA'
        keySize: 2048
        keyOps: [
          'decrypt'
          'encrypt'
          'sign'
          'unwrapKey'
          'wrapKey'
          'verify'
        ]
      }
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Administrator'
        principalId: managedIdentity.properties.principalId
        principalType: 'ServicePrincipal'
      }
      {
        roleDefinitionIdOrName: 'Key Vault Crypto Officer'
        principalId: managedIdentity.properties.principalId
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

resource anfAccount 'Microsoft.NetApp/netAppAccounts@2023-07-01' = {
  name: anfAccountName
  location: location
}

resource anfPool 'Microsoft.NetApp/netAppAccounts/capacityPools@2023-07-01' = {
  name: anfPoolName
  location: location
  parent: anfAccount
  properties: {
    serviceLevel: 'Standard'
    size: 2199023255552
  }
}

resource anfVolume 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes@2023-07-01' = {
  name: anfVolumeName
  location: location
  parent: anfPool
  properties: {
    subnetId: gatewayVNet.outputs.subnetResourceIds[3]
    usageThreshold: 2199023255552
    creationToken: 'avsVolume'
    protocolTypes: [
      'NFSv3'
    ]
    securityStyle: 'Unix'
    snapshotDirectoryVisible: true
    exportPolicy: {
      rules: [
        {
          ruleIndex: 1
          allowedClients: '0.0.0.0/0'
          hasRootAccess: true
          unixReadOnly: false
          unixReadWrite: true
          nfsv3: true
          kerberos5iReadOnly: false
          kerberos5iReadWrite: false
          kerberos5pReadOnly: false
          kerberos5pReadWrite: false
          kerberos5ReadOnly: false
          kerberos5ReadWrite: false
          nfsv41: false
        }
      ]
    }
  }
}

module jumpVMNIC '../../../../../network/network-interface/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-jumpVMNIC'
  params: {
    name: jumpVMNICName
    location: location
    ipConfigurations: [
      {
        name: 'ipconfig1'
        subnetResourceId: gatewayVNet.outputs.subnetResourceIds[1]
      }
    ]
    enableAcceleratedNetworking: true
  }
}

resource jumpVM 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: jumpVMName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v5'
    }
    osProfile: {
      computerName: 'jumpVM'
      adminUsername: jumpVMAdminUsername
      adminPassword: jumpVMAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jumpVMNIC.outputs.resourceId
        }
      ]
    }
  }
}

@description('The principal ID of the created Managed Identity.')
output managedIdentityPrincipalId string = managedIdentity.properties.principalId

@description('The resource ID of the created NAT Gateway.')
output natGatewayResourceId string = natGateway.id

@description('The resource ID of the created Virtual Network Gateway.')
output gatewayResourceId string = gateway.id

@description('The name of the created Virtual Network Gateway.')
output gatewayName string = gateway.name
