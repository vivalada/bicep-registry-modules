metadata name = 'AVS Private Cloud'
metadata description = 'This module deploys an AVS Private Cloud.'
metadata owner = 'Azure/module-maintainers'

@description('Required. The AVS Private Cloud name.')
param name string

@description('Required. The AVS Private Cloud SKU name.')
@allowed([
  'AV36'
  'AV36T'
  'AV36P'
  'AV36PT'
  'AV52'
])
param skuName string

@description('Required. The management cluster size.')
@minValue(3)
@maxValue(16)
param clusterSize int

@description('Required. The network block for the AVS Private Cloud.')
param networkBlock string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. The identity of the private cloud, if configured.')
@allowed([
  'None'
  'SystemAssigned'
])
param identityType string = 'None'

@description('Optional. The internet access configuration.')
param internetEnabled bool = false

@description('Required. Set this value to true if deploying an AVS stretch cluster.')
param stretchClusterEnabled bool = false

@description('Optional. This value represents the zone for deployment in a standard deployment or the primary zone in a stretch cluster deployment. Defaults to null to let Azure select the zone.')
param primaryZone int = 0

@description('Conditional. Required if it is a stretched cluster deployment. This value represents the secondary zone in a stretched cluster deployment.')
param secondaryZone int = 0

@description('Optional. The password value to use for the cloudadmin account password in the local domain in NSX-T. If this is left as null a random password will be generated for the deployment.')
@secure()
param nsxtPassword string?

@description('Optional. The password value to use for the cloudadmin account password in the local domain in vCenter. If this is left as null a random password will be generated for the deployment.')
@secure()
param vcenterPassword string?

@description('Required. Define if the HCX Addon will be deployed or not.')
param hcxAddonEnabled bool = false

@description('Required. The HCX offer.')
@allowed([
  'VMware MaaS Cloud Provider (Enterprise)'
  'VMware MaaS Cloud Provider'
])
param hcxOffer string = 'VMware MaaS Cloud Provider (Enterprise)'

@description('Required. Define if the SRM Addon will be deployed or not.')
param srmAddonEnabled bool = false

@description('Conditional. Required if SRM Addon is enabled. License key for SRM.')
param srmLicenseKey string = ''

@description('Conditional. Required if SRM Addon is enabled. Number of vSphere Replication Servers to be created.')
@minValue(1)
@maxValue(10)
param srmReplicationServersCount int = 1

@description('Required. Define if the ARC Addon will be deployed or not.')
param arcAddonEnabled bool = false

@description('Conditional. Required if ARC Addon is enabled. The VMware vCenter resource ID.')
param vcenterResourceId string = ''

@description('Optional. Create vNet Connection.')
param enablevNetConnectivity bool = false

@description('Conditional. Required if vNet Connectivity is enabled. The name of the ExpressRoute Virtual Network Gateway of the customer Hub Network.')
param gatewayName string = ''

@description('Conditional. Required if vNet Connectivity is enabled. The name of the Authorization Key.')
param authKeyName string = ''

@description('Conditional. Required if vNet Connectivity is enabled. The name of the Connection.')
param connectionName string = ''

@description('Optional. Add NetApp Volume.')
param addNetAppVolume bool = false

@description('Conditional. Required if Add NetApp Volume is enabled. The name of the NetApp Datastore.')
param netAppDatastoreName string = ''

@description('Conditional. Required if Add NetApp Volume is enabled. The NetApp Volume ID.')
param netAppVolumeId string = ''

@description('Conditional. Required if Add NetApp Volume is enabled. The name of the private cloud cluster.')
param privateCloudClusterName string = ''

@description('Optional. Resource tags.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingType

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments roleAssignmentType

// Variables
var privateCloudStandardProperties = {
  networkBlock: networkBlock
  internet: internetEnabled ? 'Enabled' : 'Disabled'
  managementCluster: {
    clusterSize: clusterSize
  }
  availability: {
    secondaryZone: ((secondaryZone == 0) ? null : secondaryZone)
    zone: ((primaryZone == 0) ? null : primaryZone)
    strategy: stretchClusterEnabled ? 'DualZone' : 'SingleZone'
  }
}

var privateCloudProperties = union(
  privateCloudStandardProperties,
  !empty(nsxtPassword)
    ? {
        nsxtPassword: nsxtPassword
      }
    : {},
  !empty(vcenterPassword)
    ? {
        vcenterPassword: vcenterPassword
      }
    : {}
)

var anyAddOnEnabled = hcxAddonEnabled || srmAddonEnabled || arcAddonEnabled ? true : false

var builtInRoleNames = {
  // Add other relevant built-in roles here for your resource as per BCPNFR5
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Role Based Access Control Administrator (Preview)': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
  )
  'User Access Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  )
}

// Resources
resource avmTelemetry 'Microsoft.Resources/deployments@2023-07-01' =
  if (enableTelemetry) {
    name: '46d3xbcp.res.avs-privatecloud.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}'
    properties: {
      mode: 'Incremental'
      template: {
        '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
        contentVersion: '1.0.0.0'
        resources: []
        outputs: {
          telemetry: {
            type: 'String'
            value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
          }
        }
      }
    }
  }

resource privateCloud 'Microsoft.AVS/privateClouds@2023-03-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: toLower(skuName)
  }
  identity: {
    type: identityType
  }
  properties: privateCloudProperties
}

module addOns 'addons/AVSAddons.bicep' =
  if (anyAddOnEnabled) {
    name: '${name}-addons'
    params: {
      privateCloudName: privateCloud.name
      hcxAddonEnabled: hcxAddonEnabled
      hcxOffer: hcxOffer
      srmAddonEnabled: srmAddonEnabled
      srmLicenseKey: srmLicenseKey
      srmReplicationServersCount: srmReplicationServersCount
      arcAddonEnabled: arcAddonEnabled
      vcenterResourceId: vcenterResourceId
    }
  }

module vnetConnectivity 'connectivity/connectivity.bicep' =
  if (enablevNetConnectivity) {
    name: '${name}-vnetConnection'
    params: {
      privateCloudName: privateCloud.name
      gatewayName: gatewayName
      authKeyName: authKeyName
      connectionName: connectionName
      location: location
    }
  }

module netAppVolume 'storage/storage.bicep' =
  if (addNetAppVolume) {
    name: '${name}-netAppVolume'
    params: {
      privateCloudName: privateCloud.name
      netAppDatastoreName: netAppDatastoreName
      netAppVolumeId: netAppVolumeId
      clusterName: privateCloudClusterName
    }
  }

resource privateCloud_lock 'Microsoft.Authorization/locks@2020-05-01' =
  if (!empty(lock ?? {}) && lock.?kind != 'None') {
    name: lock.?name ?? 'lock-${name}'
    properties: {
      level: lock.?kind ?? ''
      notes: lock.?kind == 'CanNotDelete'
        ? 'Cannot delete resource or child resources.'
        : 'Cannot delete or modify the resource or child resources.'
    }
    scope: privateCloud
  }

resource privateCloud_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${name}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      metrics: diagnosticSetting.?metricCategories ?? [
        {
          category: 'AllMetrics'
          timeGrain: null
          enabled: true
        }
      ]
      logs: diagnosticSetting.?logCategoriesAndGroups ?? [
        {
          categoryGroup: 'AllLogs'
          enabled: true
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: privateCloud
  }
]

resource privateCloud_RoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(privateCloud.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
    properties: {
      roleDefinitionId: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName)
        ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName]
        : contains(roleAssignment.roleDefinitionIdOrName, '/providers/Microsoft.Authorization/roleDefinitions/')
            ? roleAssignment.roleDefinitionIdOrName
            : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName)
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: privateCloud
  }
]

// Outputs
@description('The name of the deployed resource.')
output privateCloudName string = privateCloud.name

@description('The resource ID of the deployed resource.')
output privateCloudResourceId string = privateCloud.id

@description('The resource group of the deployed resource.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = privateCloud.location

// Definitions

type diagnosticSettingType = {
  @description('Optional. The name of diagnostic setting.')
  name: string?

  @description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Set to \'\' to disable log collection.')
  logCategoriesAndGroups: {
    @description('Optional. Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here.')
    category: string?

    @description('Optional. Name of a Diagnostic Log category group for a resource type this setting is applied to. Set to `allLogs` to collect all logs.')
    categoryGroup: string?
  }[]?

  @description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Set to \'\' to disable log collection.')
  metricCategories: {
    @description('Required. Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.')
    category: string
  }[]?

  @description('Optional. A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.')
  logAnalyticsDestinationType: ('Dedicated' | 'AzureDiagnostics')?

  @description('Optional. Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  workspaceResourceId: string?

  @description('Optional. Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  storageAccountResourceId: string?

  @description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
  eventHubAuthorizationRuleResourceId: string?

  @description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  eventHubName: string?

  @description('Optional. The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.')
  marketplacePartnerResourceId: string?
}[]?

type roleAssignmentType = {
  @description('Required. The name of the role to assign. If it cannot be found you can specify the role definition ID instead.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device')?

  @description('Optional. The description of the role assignment.')
  description: string?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container"')
  condition: string?

  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?

  @description('Optional. The Resource Id of the delegated managed identity resource.')
  delegatedManagedIdentityResourceId: string?
}[]?

type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. Specify the type of lock.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')?
}?
