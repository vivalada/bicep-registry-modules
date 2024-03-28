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
resource HCXAddOn 'Microsoft.AVS/privateClouds/addons@2023-03-01' =
  if (hcxAddonEnabled) {
    name: 'HCX'
    parent: privateCloud
    properties: {
      addonType: 'HCX'
      offer: hcxOffer
    }
  }
resource srmAddOn 'Microsoft.AVS/privateClouds/addons@2023-03-01' =
  if (srmAddonEnabled) {
    name: 'SRM'
    parent: privateCloud
    properties: {
      addonType: 'SRM'
      licenseKey: srmLicenseKey
    }
  }

resource vrAddOn 'Microsoft.AVS/privateClouds/addons@2023-03-01' =
  if (srmAddonEnabled) {
    name: 'VR'
    parent: privateCloud
    properties: {
      addonType: 'VR'
      vrsCount: srmReplicationServersCount
    }
    dependsOn: [
      srmAddOn
    ]
  }

resource arcAddOn 'Microsoft.AVS/privateClouds/addons@2023-03-01' =
  if (arcAddonEnabled) {
    name: 'Arc'
    parent: privateCloud
    properties: {
      addonType: 'Arc'
      vCenter: vcenterResourceId
    }
  }
