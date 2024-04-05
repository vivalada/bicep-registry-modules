# AVS Private Cloud `[Microsoft.AVS/privateClouds]`

This module deploys an AVS Private Cloud.

## Navigation

- [Resource Types](#Resource-Types)
- [Usage examples](#Usage-examples)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)
- [Data Collection](#Data-Collection)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/locks` | [2020-05-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks) |
| `Microsoft.Authorization/roleAssignments` | [2022-04-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments) |
| `Microsoft.AVS/privateClouds` | [2023-03-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.AVS/privateClouds) |
| `Microsoft.AVS/privateClouds/addons` | [2023-03-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.AVS/privateClouds/addons) |
| `Microsoft.AVS/privateClouds/authorizations` | [2023-03-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.AVS/privateClouds/authorizations) |
| `Microsoft.AVS/privateClouds/clusters/datastores` | [2023-03-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.AVS/privateClouds/clusters/datastores) |
| `Microsoft.Insights/diagnosticSettings` | [2021-05-01-preview](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings) |
| `Microsoft.Network/connections` | [2023-09-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/connections) |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/public:avm/res/avs/private-cloud:<version>`.

- [Using only defaults](#example-1-using-only-defaults)
- [Deployment of a private cloud and its dependencies for a full environment](#example-2-deployment-of-a-private-cloud-and-its-dependencies-for-a-full-environment)
- [Using large parameter set](#example-3-using-large-parameter-set)
- [Using large parameter set](#example-4-using-large-parameter-set)

### Example 1: _Using only defaults_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module privateCloud 'br/public:avm/res/avs/private-cloud:<version>' = {
  name: 'privateCloudDeployment'
  params: {
    // Required parameters
    clusterSize: 3
    name: 'sddcmin-001'
    networkBlock: '10.34.0.0/22'
    skuName: 'AV36P'
    // Non-required parameters
    location: '<location>'
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "clusterSize": {
      "value": 3
    },
    "name": {
      "value": "sddcmin-001"
    },
    "networkBlock": {
      "value": "10.34.0.0/22"
    },
    "skuName": {
      "value": "AV36P"
    },
    // Non-required parameters
    "location": {
      "value": "<location>"
    }
  }
}
```

</details>
<p>

### Example 2: _Deployment of a private cloud and its dependencies for a full environment_

This instance deploys the module with most of its features enabled, and other resources needed to use an AVS Private Cloud.


<details>

<summary>via Bicep module</summary>

```bicep
module privateCloud 'br/public:avm/res/avs/private-cloud:<version>' = {
  name: 'privateCloudDeployment'
  params: {
    // Required parameters
    clusterSize: 3
    name: 'sddcf-001'
    networkBlock: '10.42.0.0/22'
    skuName: 'AV36P'
    // Non-required parameters
    addNetAppVolume: true
    authKeyName: 'sddcf-authkey'
    connectionName: 'sddcf-conn'
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'diag-avm-01'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    enableTelemetry: true
    enablevNetConnectivity: true
    gatewayName: '<gatewayName>'
    hcxAddonEnabled: true
    identityType: '<identityType>'
    internetEnabled: false
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myLockName'
    }
    netAppDatastoreName: 'sddcf-ds'
    netAppVolumeId: '<netAppVolumeId>'
    privateCloudClusterName: 'Cluster-1'
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Contributor'
      }
    ]
    srmAddonEnabled: true
    srmReplicationServersCount: 3
    stretchClusterEnabled: false
    tags: {
      Environment: 'AVS'
      Source: 'AVM'
      TestType: 'Full'
    }
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "clusterSize": {
      "value": 3
    },
    "name": {
      "value": "sddcf-001"
    },
    "networkBlock": {
      "value": "10.42.0.0/22"
    },
    "skuName": {
      "value": "AV36P"
    },
    // Non-required parameters
    "addNetAppVolume": {
      "value": true
    },
    "authKeyName": {
      "value": "sddcf-authkey"
    },
    "connectionName": {
      "value": "sddcf-conn"
    },
    "diagnosticSettings": {
      "value": [
        {
          "eventHubAuthorizationRuleResourceId": "<eventHubAuthorizationRuleResourceId>",
          "eventHubName": "<eventHubName>",
          "metricCategories": [
            {
              "category": "AllMetrics"
            }
          ],
          "name": "diag-avm-01",
          "storageAccountResourceId": "<storageAccountResourceId>",
          "workspaceResourceId": "<workspaceResourceId>"
        }
      ]
    },
    "enableTelemetry": {
      "value": true
    },
    "enablevNetConnectivity": {
      "value": true
    },
    "gatewayName": {
      "value": "<gatewayName>"
    },
    "hcxAddonEnabled": {
      "value": true
    },
    "identityType": {
      "value": "<identityType>"
    },
    "internetEnabled": {
      "value": false
    },
    "location": {
      "value": "<location>"
    },
    "lock": {
      "value": {
        "kind": "CanNotDelete",
        "name": "myLockName"
      }
    },
    "netAppDatastoreName": {
      "value": "sddcf-ds"
    },
    "netAppVolumeId": {
      "value": "<netAppVolumeId>"
    },
    "privateCloudClusterName": {
      "value": "Cluster-1"
    },
    "roleAssignments": {
      "value": [
        {
          "principalId": "<principalId>",
          "principalType": "ServicePrincipal",
          "roleDefinitionIdOrName": "Contributor"
        }
      ]
    },
    "srmAddonEnabled": {
      "value": true
    },
    "srmReplicationServersCount": {
      "value": 3
    },
    "stretchClusterEnabled": {
      "value": false
    },
    "tags": {
      "value": {
        "Environment": "AVS",
        "Source": "AVM",
        "TestType": "Full"
      }
    }
  }
}
```

</details>
<p>

### Example 3: _Using large parameter set_

This instance deploys the module with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module privateCloud 'br/public:avm/res/avs/private-cloud:<version>' = {
  name: 'privateCloudDeployment'
  params: {
    // Required parameters
    clusterSize: 3
    name: 'sddcmax-001'
    networkBlock: '10.64.0.0/22'
    skuName: 'AV36P'
    // Non-required parameters
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'diag-avm-01'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    identityType: '<identityType>'
    internetEnabled: true
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myLockName'
    }
    nsxtPassword: '<nsxtPassword>'
    primaryZone: 1
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Contributor'
      }
    ]
    secondaryZone: 2
    stretchClusterEnabled: false
    tags: {
      Environment: 'Test'
      Source: 'AVM'
      TestType: 'Interfaces'
    }
    vcenterPassword: '<vcenterPassword>'
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "clusterSize": {
      "value": 3
    },
    "name": {
      "value": "sddcmax-001"
    },
    "networkBlock": {
      "value": "10.64.0.0/22"
    },
    "skuName": {
      "value": "AV36P"
    },
    // Non-required parameters
    "diagnosticSettings": {
      "value": [
        {
          "eventHubAuthorizationRuleResourceId": "<eventHubAuthorizationRuleResourceId>",
          "eventHubName": "<eventHubName>",
          "metricCategories": [
            {
              "category": "AllMetrics"
            }
          ],
          "name": "diag-avm-01",
          "storageAccountResourceId": "<storageAccountResourceId>",
          "workspaceResourceId": "<workspaceResourceId>"
        }
      ]
    },
    "identityType": {
      "value": "<identityType>"
    },
    "internetEnabled": {
      "value": true
    },
    "location": {
      "value": "<location>"
    },
    "lock": {
      "value": {
        "kind": "CanNotDelete",
        "name": "myLockName"
      }
    },
    "nsxtPassword": {
      "value": "<nsxtPassword>"
    },
    "primaryZone": {
      "value": 1
    },
    "roleAssignments": {
      "value": [
        {
          "principalId": "<principalId>",
          "principalType": "ServicePrincipal",
          "roleDefinitionIdOrName": "Contributor"
        }
      ]
    },
    "secondaryZone": {
      "value": 2
    },
    "stretchClusterEnabled": {
      "value": false
    },
    "tags": {
      "value": {
        "Environment": "Test",
        "Source": "AVM",
        "TestType": "Interfaces"
      }
    },
    "vcenterPassword": {
      "value": "<vcenterPassword>"
    }
  }
}
```

</details>
<p>

### Example 4: _Using large parameter set_

This instance deploys the module with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module privateCloud 'br/public:avm/res/avs/private-cloud:<version>' = {
  name: 'privateCloudDeployment'
  params: {
    // Required parameters
    clusterSize: 6
    name: 'sddcwaf-001'
    networkBlock: '10.53.0.0/22'
    skuName: 'AV36P'
    // Non-required parameters
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'diag-avm-01'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    identityType: '<identityType>'
    internetEnabled: false
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myLockName'
    }
    nsxtPassword: '<nsxtPassword>'
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Contributor'
      }
    ]
    stretchClusterEnabled: true
    tags: {
      Environment: 'Test'
      Source: 'AVM'
      TestType: 'Interfaces'
    }
    vcenterPassword: '<vcenterPassword>'
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "clusterSize": {
      "value": 6
    },
    "name": {
      "value": "sddcwaf-001"
    },
    "networkBlock": {
      "value": "10.53.0.0/22"
    },
    "skuName": {
      "value": "AV36P"
    },
    // Non-required parameters
    "diagnosticSettings": {
      "value": [
        {
          "eventHubAuthorizationRuleResourceId": "<eventHubAuthorizationRuleResourceId>",
          "eventHubName": "<eventHubName>",
          "metricCategories": [
            {
              "category": "AllMetrics"
            }
          ],
          "name": "diag-avm-01",
          "storageAccountResourceId": "<storageAccountResourceId>",
          "workspaceResourceId": "<workspaceResourceId>"
        }
      ]
    },
    "identityType": {
      "value": "<identityType>"
    },
    "internetEnabled": {
      "value": false
    },
    "location": {
      "value": "<location>"
    },
    "lock": {
      "value": {
        "kind": "CanNotDelete",
        "name": "myLockName"
      }
    },
    "nsxtPassword": {
      "value": "<nsxtPassword>"
    },
    "roleAssignments": {
      "value": [
        {
          "principalId": "<principalId>",
          "principalType": "ServicePrincipal",
          "roleDefinitionIdOrName": "Contributor"
        }
      ]
    },
    "stretchClusterEnabled": {
      "value": true
    },
    "tags": {
      "value": {
        "Environment": "Test",
        "Source": "AVM",
        "TestType": "Interfaces"
      }
    },
    "vcenterPassword": {
      "value": "<vcenterPassword>"
    }
  }
}
```

</details>
<p>


## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`arcAddonEnabled`](#parameter-arcaddonenabled) | bool | Define if the ARC Addon will be deployed or not. |
| [`clusterSize`](#parameter-clustersize) | int | The management cluster size. |
| [`hcxAddonEnabled`](#parameter-hcxaddonenabled) | bool | Define if the HCX Addon will be deployed or not. |
| [`hcxOffer`](#parameter-hcxoffer) | string | The HCX offer. |
| [`name`](#parameter-name) | string | The AVS Private Cloud name. |
| [`networkBlock`](#parameter-networkblock) | string | The network block for the AVS Private Cloud. |
| [`skuName`](#parameter-skuname) | string | The AVS Private Cloud SKU name. |
| [`srmAddonEnabled`](#parameter-srmaddonenabled) | bool | Define if the SRM Addon will be deployed or not. |
| [`stretchClusterEnabled`](#parameter-stretchclusterenabled) | bool | Set this value to true if deploying an AVS stretch cluster. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authKeyName`](#parameter-authkeyname) | string | Required if vNet Connectivity is enabled. The name of the Authorization Key. |
| [`connectionName`](#parameter-connectionname) | string | Required if vNet Connectivity is enabled. The name of the Connection. |
| [`gatewayName`](#parameter-gatewayname) | string | Required if vNet Connectivity is enabled. The name of the ExpressRoute Virtual Network Gateway of the customer Hub Network. |
| [`netAppDatastoreName`](#parameter-netappdatastorename) | string | Required if Add NetApp Volume is enabled. The name of the NetApp Datastore. |
| [`netAppVolumeId`](#parameter-netappvolumeid) | string | Required if Add NetApp Volume is enabled. The NetApp Volume ID. |
| [`privateCloudClusterName`](#parameter-privatecloudclustername) | string | Required if Add NetApp Volume is enabled. The name of the private cloud cluster. |
| [`secondaryZone`](#parameter-secondaryzone) | int | Required if it is a stretched cluster deployment. This value represents the secondary zone in a stretched cluster deployment. |
| [`srmLicenseKey`](#parameter-srmlicensekey) | string | Required if SRM Addon is enabled. License key for SRM. |
| [`srmReplicationServersCount`](#parameter-srmreplicationserverscount) | int | Required if SRM Addon is enabled. Number of vSphere Replication Servers to be created. |
| [`vcenterResourceId`](#parameter-vcenterresourceid) | string | Required if ARC Addon is enabled. The VMware vCenter resource ID. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`addNetAppVolume`](#parameter-addnetappvolume) | bool | Add NetApp Volume. |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | array | The diagnostic settings of the service. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`enablevNetConnectivity`](#parameter-enablevnetconnectivity) | bool | Create vNet Connection. |
| [`identityType`](#parameter-identitytype) | string | The identity of the private cloud, if configured. |
| [`internetEnabled`](#parameter-internetenabled) | bool | The internet access configuration. |
| [`location`](#parameter-location) | string | Location for all resources. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`nsxtPassword`](#parameter-nsxtpassword) | securestring | The password value to use for the cloudadmin account password in the local domain in NSX-T. If this is left as null a random password will be generated for the deployment. |
| [`primaryZone`](#parameter-primaryzone) | int | This value represents the zone for deployment in a standard deployment or the primary zone in a stretch cluster deployment. Defaults to null to let Azure select the zone. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`tags`](#parameter-tags) | object | Resource tags. |
| [`vcenterPassword`](#parameter-vcenterpassword) | securestring | The password value to use for the cloudadmin account password in the local domain in vCenter. If this is left as null a random password will be generated for the deployment. |

### Parameter: `arcAddonEnabled`

Define if the ARC Addon will be deployed or not.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `clusterSize`

The management cluster size.

- Required: Yes
- Type: int

### Parameter: `hcxAddonEnabled`

Define if the HCX Addon will be deployed or not.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `hcxOffer`

The HCX offer.

- Required: No
- Type: string
- Default: `'VMware MaaS Cloud Provider (Enterprise)'`
- Allowed:
  ```Bicep
  [
    'VMware MaaS Cloud Provider'
    'VMware MaaS Cloud Provider (Enterprise)'
  ]
  ```

### Parameter: `name`

The AVS Private Cloud name.

- Required: Yes
- Type: string

### Parameter: `networkBlock`

The network block for the AVS Private Cloud.

- Required: Yes
- Type: string

### Parameter: `skuName`

The AVS Private Cloud SKU name.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AV36'
    'AV36P'
    'AV36PT'
    'AV36T'
    'AV52'
  ]
  ```

### Parameter: `srmAddonEnabled`

Define if the SRM Addon will be deployed or not.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `stretchClusterEnabled`

Set this value to true if deploying an AVS stretch cluster.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `authKeyName`

Required if vNet Connectivity is enabled. The name of the Authorization Key.

- Required: No
- Type: string
- Default: `''`

### Parameter: `connectionName`

Required if vNet Connectivity is enabled. The name of the Connection.

- Required: No
- Type: string
- Default: `''`

### Parameter: `gatewayName`

Required if vNet Connectivity is enabled. The name of the ExpressRoute Virtual Network Gateway of the customer Hub Network.

- Required: No
- Type: string
- Default: `''`

### Parameter: `netAppDatastoreName`

Required if Add NetApp Volume is enabled. The name of the NetApp Datastore.

- Required: No
- Type: string
- Default: `''`

### Parameter: `netAppVolumeId`

Required if Add NetApp Volume is enabled. The NetApp Volume ID.

- Required: No
- Type: string
- Default: `''`

### Parameter: `privateCloudClusterName`

Required if Add NetApp Volume is enabled. The name of the private cloud cluster.

- Required: No
- Type: string
- Default: `''`

### Parameter: `secondaryZone`

Required if it is a stretched cluster deployment. This value represents the secondary zone in a stretched cluster deployment.

- Required: No
- Type: int
- Default: `0`

### Parameter: `srmLicenseKey`

Required if SRM Addon is enabled. License key for SRM.

- Required: No
- Type: string
- Default: `''`

### Parameter: `srmReplicationServersCount`

Required if SRM Addon is enabled. Number of vSphere Replication Servers to be created.

- Required: No
- Type: int
- Default: `1`

### Parameter: `vcenterResourceId`

Required if ARC Addon is enabled. The VMware vCenter resource ID.

- Required: No
- Type: string
- Default: `''`

### Parameter: `addNetAppVolume`

Add NetApp Volume.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `diagnosticSettings`

The diagnostic settings of the service.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`eventHubAuthorizationRuleResourceId`](#parameter-diagnosticsettingseventhubauthorizationruleresourceid) | string | Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| [`eventHubName`](#parameter-diagnosticsettingseventhubname) | string | Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`logAnalyticsDestinationType`](#parameter-diagnosticsettingsloganalyticsdestinationtype) | string | A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type. |
| [`logCategoriesAndGroups`](#parameter-diagnosticsettingslogcategoriesandgroups) | array | The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Set to '' to disable log collection. |
| [`marketplacePartnerResourceId`](#parameter-diagnosticsettingsmarketplacepartnerresourceid) | string | The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs. |
| [`metricCategories`](#parameter-diagnosticsettingsmetriccategories) | array | The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Set to '' to disable log collection. |
| [`name`](#parameter-diagnosticsettingsname) | string | The name of diagnostic setting. |
| [`storageAccountResourceId`](#parameter-diagnosticsettingsstorageaccountresourceid) | string | Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`workspaceResourceId`](#parameter-diagnosticsettingsworkspaceresourceid) | string | Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |

### Parameter: `diagnosticSettings.eventHubAuthorizationRuleResourceId`

Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.eventHubName`

Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logAnalyticsDestinationType`

A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureDiagnostics'
    'Dedicated'
  ]
  ```

### Parameter: `diagnosticSettings.logCategoriesAndGroups`

The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Set to '' to disable log collection.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-diagnosticsettingslogcategoriesandgroupscategory) | string | Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here. |
| [`categoryGroup`](#parameter-diagnosticsettingslogcategoriesandgroupscategorygroup) | string | Name of a Diagnostic Log category group for a resource type this setting is applied to. Set to `allLogs` to collect all logs. |

### Parameter: `diagnosticSettings.logCategoriesAndGroups.category`

Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logCategoriesAndGroups.categoryGroup`

Name of a Diagnostic Log category group for a resource type this setting is applied to. Set to `allLogs` to collect all logs.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.marketplacePartnerResourceId`

The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.metricCategories`

The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Set to '' to disable log collection.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-diagnosticsettingsmetriccategoriescategory) | string | Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics. |

### Parameter: `diagnosticSettings.metricCategories.category`

Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.

- Required: Yes
- Type: string

### Parameter: `diagnosticSettings.name`

The name of diagnostic setting.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.storageAccountResourceId`

Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.workspaceResourceId`

Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enablevNetConnectivity`

Create vNet Connection.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `identityType`

The identity of the private cloud, if configured.

- Required: No
- Type: string
- Default: `'None'`
- Allowed:
  ```Bicep
  [
    'None'
    'SystemAssigned'
  ]
  ```

### Parameter: `internetEnabled`

The internet access configuration.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `location`

Location for all resources.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `lock`

The lock settings of the service.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-lockkind) | string | Specify the type of lock. |
| [`name`](#parameter-lockname) | string | Specify the name of lock. |

### Parameter: `lock.kind`

Specify the type of lock.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'CanNotDelete'
    'None'
    'ReadOnly'
  ]
  ```

### Parameter: `lock.name`

Specify the name of lock.

- Required: No
- Type: string

### Parameter: `nsxtPassword`

The password value to use for the cloudadmin account password in the local domain in NSX-T. If this is left as null a random password will be generated for the deployment.

- Required: No
- Type: securestring

### Parameter: `primaryZone`

This value represents the zone for deployment in a standard deployment or the primary zone in a stretch cluster deployment. Defaults to null to let Azure select the zone.

- Required: No
- Type: int
- Default: `0`

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-roleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-roleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-roleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-roleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-roleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-roleassignmentsdescription) | string | The description of the role assignment. |
| [`principalType`](#parameter-roleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `roleAssignments.principalType`

The principal type of the assigned principal ID.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
  ]
  ```

### Parameter: `tags`

Resource tags.

- Required: No
- Type: object

### Parameter: `vcenterPassword`

The password value to use for the cloudadmin account password in the local domain in vCenter. If this is left as null a random password will be generated for the deployment.

- Required: No
- Type: securestring


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the deployed resource. |
| `resourceGroupName` | string | The resource group of the deployed resource. |
| `resourceId` | string | The resource ID of the deployed resource. |

## Cross-referenced modules

_None_

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the [repository](https://aka.ms/avm/telemetry). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
