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
