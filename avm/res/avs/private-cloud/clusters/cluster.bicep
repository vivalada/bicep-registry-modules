metadata name = 'Additional cluster'
metadata description = 'If needed to deploy multiple clusters in one SDDC.'

@description('Required. The name of the AVS Private Cloud.')
param privateCloudName string

@description('Required. The name of the AVS Cluster.')
param clusterName string

@description('Required. The SKU of the AVS Cluster.')
@allowed([
  'AV36'
  'AV36T'
  'AV36P'
  'AV36PT'
  'AV52'
])
param skuName string

resource privateCloud 'Microsoft.AVS/privateClouds@2023-03-01' existing = {
  name: privateCloudName
}

resource cluster 'Microsoft.AVS/privateClouds/clusters@2023-03-01' = {
  name: clusterName
  parent: privateCloud
  sku: {
    name: skuName
  }
  properties: {
    clusterSize: 3
    hosts: []
  }
}
