metadata name = 'AVS Private Cloud Clusters Datastores'
metadata description = 'This module attaches a NetApp storage to the AVS cluster, when Datastore connectivity is enabled.'
metadata owner = 'Azure/module-maintainers'

@description('Required. The name of the AVS private cloud.')
param privateCloudName string

@description('Required. The name of the AVS cluster.')
param clusterName string = 'Cluster-1'

@description('Required. The name of the NetApp datastore.')
param netAppDatastoreName string

@description('Required. The ID of the NetApp volume.')
param netAppVolumeId string

resource privateCloud 'Microsoft.AVS/privateClouds@2023-03-01' existing = {
  name: privateCloudName
}

resource privateCloudCluster 'Microsoft.AVS/privateClouds/clusters@2023-03-01' existing = {
  parent: privateCloud
  name: clusterName
}

resource netAppDatastore 'Microsoft.AVS/privateClouds/clusters/datastores@2023-03-01' = {
  parent: privateCloudCluster
  name: netAppDatastoreName
  properties: {
    netAppVolume: {
      id: netAppVolumeId
    }
  }
}

//Outputs
@description('The name of the NetApp datastore.')
output name string = netAppDatastore.name

@description('The Resource ID of the NetApp datastore.')
output resourceId string = netAppDatastore.id

@description('The resource group of the deployed resource.')
output resourceGroupName string = resourceGroup().name
