targetScope = 'subscription'

metadata name = 'Deployment of a private cloud and its dependencies for a full environment'
metadata description = 'This instance deploys the module with most of its features enabled, and other resources needed to use an AVS Private Cloud.'

// Parameters

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-avs.privatecloud-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

@description('Generated. Used as a basis for unique resource names.')
param baseTime string = utcNow('u')

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'sddcf'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

@description('Optional. The identity of the private cloud, if configured.')
param identityType string = 'SystemAssigned'

@description('Optional. The password value to use for the Jump VM Administrator account.')
@secure()
param jumpVMAdminPassword string = newGuid()

// Dependencies
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-nestedDependencies'
  params: {
    managedIdentityName: 'dep-${namePrefix}-${serviceShort}-mi'
    natGatewayPublicIPName: 'dep-${namePrefix}-${serviceShort}-natgw-ip'
    natGatewayName: 'dep-${namePrefix}-${serviceShort}-natgw'
    gatewayVNetName: 'dep-${namePrefix}-${serviceShort}-gwvnet'
    gatewayPublicIPName: 'dep-${namePrefix}-${serviceShort}-gw-ip'
    gatewayName: 'dep-${namePrefix}-${serviceShort}-gw'
    bastionPublicIPName: 'dep-${namePrefix}-${serviceShort}-bastion-ip'
    bastionName: 'dep-${namePrefix}-${serviceShort}-bastion'
    keyVaultName: 'dep-${namePrefix}-${serviceShort}-${substring(uniqueString(baseTime), 0, 3)}-kv'
    anfAccountName: 'dep-${namePrefix}-${serviceShort}-anfacc'
    anfPoolName: 'dep-${namePrefix}-${serviceShort}-anfpool'
    anfVolumeName: 'dep-${namePrefix}-${serviceShort}-anfvol'
    jumpVMNICName: 'dep-${namePrefix}-${serviceShort}-jumpvm-nic'
    jumpVMName: 'dep-${namePrefix}-${serviceShort}-jumpvm'
    jumpVMAdminUsername: 'avsadmin'
    jumpVMAdminPassword: jumpVMAdminPassword
    location: location
  }
}

module diagnosticDependencies '../../../../../../utilities/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep${namePrefix}${serviceShort}diasa01'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}-${serviceShort}-law'
    eventHubNamespaceEventHubName: 'dep-${namePrefix}-${serviceShort}-evh'
    eventHubNamespaceName: 'dep-${namePrefix}-${serviceShort}-evhns'
    location: location
  }
}

// Test Execution
@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, location)}-test-${serviceShort}-${iteration}'
    params: {
      enableTelemetry: true
      name: '${namePrefix}-${serviceShort}-001'
      location: location
      skuName: 'AV36P'
      clusterSize: 3
      networkBlock: '10.42.0.0/22'
      internetEnabled: false
      stretchClusterEnabled: false
      identityType: identityType
      enablevNetConnectivity: true
      gatewayName: nestedDependencies.outputs.gatewayName
      authKeyName: '${namePrefix}-${serviceShort}-authkey'
      connectionName: '${namePrefix}-${serviceShort}-conn'
      hcxAddonEnabled: true
      srmAddonEnabled: true
      srmReplicationServersCount: 3
      addNetAppVolume: true
      netAppDatastoreName: '${namePrefix}-${serviceShort}-ds'
      netAppVolumeId: nestedDependencies.outputs.anfVolumeResourceId
      privateCloudClusterName: 'Cluster-1'
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
        'hidden-title': 'This is visible in the resource name'
        Environment: 'Non-Prod'
        Role: 'DeploymentValidation'
      }
    }
    dependsOn: [
      nestedDependencies
      diagnosticDependencies
    ]
  }
]
