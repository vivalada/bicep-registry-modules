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

resource natGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: natGatewayPublicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
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
        id: natGatewayPublicIP.id
      }
    ]
  }
}

resource gatewayVNet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: gatewayVNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.100.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.100.0.0/24'
        }
      }
      {
        name: 'VMSubnet'
        properties: {
          addressPrefix: '10.100.1.0/24'
          natGateway: {
            id: natGateway.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.100.2.0/24'
        }
      }
      {
        name: 'ANFSubnet'
        properties: {
          addressPrefix: '10.100.3.0/24'
          delegations: [
            {
              name: 'Microsoft.NetApp/volumes'
              properties: {
                serviceName: 'Microsoft.NetApp/volumes'
              }
            }
          ]
        }
      }
    ]
  }
}

resource gatewayPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: gatewayPublicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
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
            id: '${gatewayVNet.id}/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: gatewayPublicIP.id
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
}

resource bastionPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: bastionPublicIPName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2023-09-01' = {
  name: bastionName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        properties: {
          subnet: {
            id: '${gatewayVNet.id}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: bastionPublicIP.id
          }
        }
        name: 'ipConfigAzureBastionSubnet'
      }
    ]
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: true
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    accessPolicies: []
  }
}

resource keyVaultKey 'Microsoft.KeyVault/vaults/keys@2023-07-01' = {
  parent: keyVault
  name: 'cmk-disk-key'
  properties: {
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
}

resource keyVaultAdministratorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
}

resource keyVaultAdministrator 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, managedIdentity.id, keyVaultAdministratorRoleDefinition.id)
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultAdministratorRoleDefinition.id
    principalId: managedIdentity.properties.principalId
  }
}

resource keyVaultCryptoOfficerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
}

resource keyVaultCryptoOfficer 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, managedIdentity.id, keyVaultCryptoOfficerRoleDefinition.id)
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultCryptoOfficerRoleDefinition.id
    principalId: managedIdentity.properties.principalId
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
    subnetId: '${gatewayVNet.id}/subnets/ANFSubnet'
    usageThreshold: 2199023255552
    creationToken: 'avsVolume'
    avsDataStore: 'Enabled'
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

resource jumpVMNIC 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: jumpVMNICName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${gatewayVNet.id}/subnets/VMSubnet'
          }
        }
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
          id: jumpVMNIC.id
        }
      ]
    }
  }
}

@description('The principal ID of the created Managed Identity.')
output managedIdentityPrincipalId string = managedIdentity.properties.principalId

@description('The resource ID of the created NAT Gateway Public IP Address.')
output natGatewayPublicIPResourceId string = natGatewayPublicIP.id

@description('The name of the created NAT Gateway Public IP Address.')
output natGatewayPublicIPName string = natGatewayPublicIP.name

@description('The resource ID of the created NAT Gateway.')
output natGatewayResourceId string = natGateway.id

@description('The name of the created NAT Gateway.')
output natGatewayName string = natGateway.name

@description('The resource ID of the created Gateway Virtual Network.')
output gatewayVNetResourceId string = gatewayVNet.id

@description('The name of the created Gateway Virtual Network.')
output gatewayVNetName string = gatewayVNet.name

@description('The resource ID of the created Gateway Public IP Address.')
output gatewayPublicIPResourceId string = gatewayPublicIP.id

@description('The name of the created Gateway Public IP Address.')
output gatewayPublicIPName string = gatewayPublicIP.name

@description('The resource ID of the created Virtual Network Gateway.')
output gatewayResourceId string = gateway.id

@description('The name of the created Virtual Network Gateway.')
output gatewayName string = gateway.name

@description('The resource ID of the created Bastion Public IP Address.')
output bastionPublicIPResourceId string = bastionPublicIP.id

@description('The name of the created Bastion Public IP Address.')
output bastionPublicIPName string = bastionPublicIP.name

@description('The resource ID of the created Bastion Host.')
output bastionResourceId string = bastionHost.id

@description('The name of the created Bastion Host.')
output bastionName string = bastionHost.name

@description('The resource ID of the created Key Vault.')
output keyVaultResourceId string = keyVault.id

@description('The name of the created Key Vault.')
output keyVaultName string = keyVault.name

@description('The resource ID of the created ANF Account.')
output anfAccountResourceId string = anfAccount.id

@description('The name of the created ANF Account.')
output anfAccountName string = anfAccount.name

@description('The resource ID of the created ANF Pool.')
output anfPoolResourceId string = anfPool.id

@description('The name of the created ANF Pool.')
output anfPoolName string = anfPool.name

@description('The resource ID of the created ANF Volume.')
output anfVolumeResourceId string = anfVolume.id

@description('The resource ID of the created Jump VM NIC.')
output jumpVMNICResourceId string = jumpVMNIC.id

@description('The name of the created Jump VM NIC.')
output jumpVMNICName string = jumpVMNIC.name

@description('The resource ID of the created Jump VM.')
output jumpVMResourceId string = jumpVM.id

@description('The name of the created Jump VM.')
output jumpVMName string = jumpVM.name
