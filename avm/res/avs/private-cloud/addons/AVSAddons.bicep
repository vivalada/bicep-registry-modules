targetScope = 'resourceGroup'

@description('Required. The name of the AVS private cloud.')
param privateCloudName string

@description('Required. Define if the HCX Addon will be deployed or not.')
param hcxAddonEnabled bool

@description('Required. Define if the SRM Addon will be deployed or not.')
param srmAddonEnabled bool

@description('Optional. License key for SRM, if SRM Addon is enabled.')
param srmLicenseKey string

@description('Optional. Number of vSphere Replication Servers to be created if SRM Addon is enabled.')
param srmReplicationServersCount int

module hcx 'HCX/HCX.bicep' = if (hcxAddonEnabled) {
  name: '${deployment().name}-hcx'
  params: {
    privateCloudName: privateCloudName
  }
}

module srm 'SRM/SRM.bicep' = if (srmAddonEnabled) {
  name: '${deployment().name}-srm'
  params: {
    privateCloudName: privateCloudName
    srmLicenseKey: srmLicenseKey
    srmReplicationServersCount: srmReplicationServersCount
  }
}
