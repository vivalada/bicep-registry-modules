targetScope = 'subscription'

metadata name = 'Using only defaults'
metadata description = 'This instance deploys the module with the minimum set of required parameters.'

// Parameters

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-avs.privatecloud-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'sddcmin'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = 'avm'

@description('Optional. Set the NSX-T Manager password when the private cloud is created.')
@secure()
param nsxtPassword string

@description('Optional. Set the vCenter Admin password when the private cloud is created.')
@secure()
param vcenterPassword string

// Variables
var avsSDDCConfigurations = [
  {
    serviceShort: 'sddcmin'
    namePrefix: 'avm'
    skuName: 'AV36'
    internet: 'Enabled'
    clusterSize: 3
    networkBlock: '10.87.0.0/22'
    nsxtPassword: nsxtPassword
    vcenterPassword: vcenterPassword
    hcxAddonEnabled: false
  }
]

// Dependencies
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Test Execution
@batchSize(1)
module testDeployment '../../../main.bicep' = [for (config, iteration) in avsSDDCConfigurations: {
  scope: resourceGroup
  name: '${config.namePrefix}${config.serviceShort}${iteration}'
  params: {
    name: '${config.namePrefix}-${config.serviceShort}-00${iteration}'
    deploymentPrefix: config.namePrefix
    location: location
    skuName: config.skuName
    internet: config.internet
    clusterSize: config.clusterSize
    networkBlock: config.networkBlock
    nsxtPassword: config.nsxtPassword
    vcenterPassword: config.vcenterPassword
    hcxAddonEnabled: config.hcxAddonEnabled
  }
}]
