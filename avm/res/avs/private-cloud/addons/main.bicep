metadata name = 'AVS Private Cloud Addons'
metadata description = 'This module deploys a AVS Addons, when any Addon is enabled.'
metadata owner = 'Azure/module-maintainers'

@description('Required. The name of the AVS private cloud.')
param privateCloudName string

@description('Required. Define if the HCX Addon will be deployed or not.')
param hcxAddonEnabled bool

@description('Required. The HCX offer.')
param hcxOffer string = 'VMware MaaS Cloud Provider (Enterprise)'

@description('Required. Define if the SRM Addon will be deployed or not.')
param srmAddonEnabled bool

@description('Optional. License key for SRM, if SRM Addon is enabled.')
param srmLicenseKey string

@description('Optional. Number of vSphere Replication Servers to be created if SRM Addon is enabled.')
param srmReplicationServersCount int

@description('Required. Define if the ARC Addon will be deployed or not.')
param arcAddonEnabled bool

@description('Conditional. Required if ARC Addon is enabled. The VMware vCenter resource ID.')
param vcenterResourceId string

resource privateCloud 'Microsoft.AVS/privateClouds@2023-03-01' existing = {
  name: privateCloudName
}

resource HCX 'Microsoft.AVS/privateClouds/addons@2023-03-01' =
  if (hcxAddonEnabled) {
    name: 'hcx'
    parent: privateCloud
    properties: {
      addonType: 'HCX'
      offer: hcxOffer
    }
  }
resource SRM 'Microsoft.AVS/privateClouds/addons@2023-03-01' =
  if (srmAddonEnabled) {
    name: 'srm'
    parent: privateCloud
    properties: {
      addonType: 'SRM'
      licenseKey: (srmLicenseKey == '') ? null : srmLicenseKey
    }
  }

resource VR 'Microsoft.AVS/privateClouds/addons@2023-03-01' =
  if (srmAddonEnabled) {
    name: 'vr'
    parent: privateCloud
    properties: {
      addonType: 'VR'
      vrsCount: srmReplicationServersCount
    }
    dependsOn: [
      SRM
    ]
  }

resource Arc 'Microsoft.AVS/privateClouds/addons@2023-03-01' =
  if (arcAddonEnabled) {
    name: 'Arc'
    parent: privateCloud
    properties: {
      addonType: 'Arc'
      vCenter: vcenterResourceId
    }
  }

// Outputs
@description('The resource group of the deployed resource.')
output resourceGroupName string = resourceGroup().name

@description('The name of the HCX Addon.')
output name string = hcxAddonEnabled ? HCX.name : ''

@description('The ResourceId of the HCX Addon.')
output resourceId string = hcxAddonEnabled ? HCX.id : ''

@description('The name of the SRM Addon.')
output srmAddonName string = srmAddonEnabled ? SRM.name : ''

@description('The ResourceId of the SRM Addon.')
output srmAddonId string = srmAddonEnabled ? SRM.id : ''

@description('The name of the VR Addon.')
output vrAddonName string = srmAddonEnabled ? VR.name : ''

@description('The ResourceId of the VR Addon.')
output vrAddonId string = srmAddonEnabled ? VR.id : ''

@description('The name of the ARC Addon.')
output arcAddonName string = arcAddonEnabled ? Arc.name : ''

@description('The ResourceId of the ARC Addon.')
output arcAddonId string = arcAddonEnabled ? Arc.id : ''
