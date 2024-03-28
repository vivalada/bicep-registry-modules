targetScope = 'subscription'

metadata name = 'Using large parameter set'
metadata description = 'This instance deploys the module with most of its features enabled.'

// Parameters

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-avs.privatecloud-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'sddcmax'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = 'avm'

@description('Optional. The identity of the private cloud, if configured.')
param identityType string = 'SystemAssigned'

@description('Optional. Set the NSX-T Manager password when the private cloud is created.')
@secure()
param nsxtPassword string

@description('Optional. Set the vCenter Admin password when the private cloud is created.')
@secure()
param vcenterPassword string

// Dependencies
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-nestedDependencies'
  params: {
    managedIdentityName: 'dep-${namePrefix}-msi-${serviceShort}'
    location: location
  }
}

module diagnosticDependencies '../../../../../../utilities/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep${namePrefix}diasa${serviceShort}01'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}-law-${serviceShort}'
    eventHubNamespaceEventHubName: 'dep-${namePrefix}-evh-${serviceShort}'
    eventHubNamespaceName: 'dep-${namePrefix}-evhns-${serviceShort}'
    location: location
  }
}

// Test Execution
@batchSize(1)
module testPrivateCloud '../../../main.bicep' = [
  for iteration in ['init']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, location)}-test-${serviceShort}-${iteration}'
    params: {
      name: '${namePrefix}-${serviceShort}-001'
      location: location
      skuName: 'AV36P'
      clusterSize: 3
      networkBlock: '10.64.0.0/22'
      internetEnabled: true
      stretchClusterEnabled: false
      primaryZone: 1
      secondaryZone: 2
      identityType: identityType
      nsxtPassword: nsxtPassword
      vcenterPassword: vcenterPassword
      diagnosticSettings: [
        {
          name: 'diag-avm-01'
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
          eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
          storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
          workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
        }
      ]
      lock: {
        kind: 'CanNotDelete'
        name: 'myLockName'
      }
      roleAssignments: [
        {
          roleDefinitionIdOrName: 'Contributor'
          principalId: nestedDependencies.outputs.managedIdentityPrincipalId
          principalType: 'ServicePrincipal'
        }
      ]
      tags: {
        Environment: 'Test'
        Source: 'AVM'
        TestType: 'Interfaces'
      }
    }
    dependsOn: [
      nestedDependencies
      diagnosticDependencies
    ]
  }
]
