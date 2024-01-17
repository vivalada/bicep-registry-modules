metadata name = 'SRM AddOn'
metadata description = 'Deplloys the SRM AddOn in the AVS Private Cloud.'

@description('Required. The name of the AVS Private Cloud.')
param privateCloudName string

@description('Required. The name of the SRM.')
param srmAddOnName string = 'SRM'

@description('Required. SRM License Key.')
param srmLicenseKey string

@description('Required. Number of vSphere Replication Servers.')
@minValue(1)
@maxValue(10)
param srmReplicationServersCount int

resource privateCloud 'Microsoft.AVS/privateClouds@2023-03-01' existing = {
  name: privateCloudName
}

resource srmAddOn 'Microsoft.AVS/privateClouds/addons@2023-03-01' = {
  name: srmAddOnName
  parent: privateCloud
  properties: {
    addonType: 'SRM'
    licenseKey: srmLicenseKey
  }
}

resource VR 'Microsoft.AVS/privateClouds/addons@2023-03-01' = {
  name: 'vr'
  parent: privateCloud
  properties: {
    addonType: 'VR'
    vrsCount: srmReplicationServersCount
  }
  dependsOn: [
    srmAddOn
  ]
}
