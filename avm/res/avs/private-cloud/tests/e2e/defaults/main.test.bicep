targetScope = 'subscription'

metadata name = 'Using only defaults'
metadata description = 'This instance deploys the module with the minimum set of required parameters.'

// Parameters

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = '${namePrefix}-avs-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'test'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = 'avm'

param networkBlock string = '10.145.0.0/22'

@description('Required. The private cloud SKU.')
param sku string = 'AV36'
param clusterSize int = 3
param internet string = 'Disabled'
param tags object = {
  'Created Using': 'AVM Bicep Module'
}
param identityType string = 'SystemAssigned'
// Dependencies

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Test Execution

module testDeployment '../../../main.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-test-${serviceShort}'
  params: {
    name: '${namePrefix}-${serviceShort}-001'
    location: location
    tags: tags
    identityType: identityType
    networkBlock: networkBlock
    sku: sku
    clusterSize: clusterSize
    internet: internet
    lock: null
    diagnosticSettings: null
    roleAssignments: null
  }
}
