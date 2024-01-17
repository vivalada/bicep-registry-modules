metadata name = 'HCX AddOn'
metadata description = 'Deplloys the HCX AddOn in the AVS Private Cloud.'

@description('Required. The name of the AVS Private Cloud.')
param privateCloudName string

@description('Required. The HCX offer.')
@allowed([
  'VMware MaaS Cloud Provider (Enterprise)'
  'VMware MaaS Cloud Provider'
])
param hcxOffer string = 'VMware MaaS Cloud Provider (Enterprise)'

resource privateCloud 'Microsoft.AVS/privateClouds@2023-03-01' existing = {
  name: privateCloudName
}

resource hcxAddOn 'Microsoft.AVS/privateClouds/addons@2023-03-01' = {
  name: 'HCX'
  parent: privateCloud
  properties: {
    addonType: 'HCX'
    offer: hcxOffer
  }
}
