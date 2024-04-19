# AVS Private Cloud Addons `[Microsoft.AVS/privateClouds/addons]`

This module deploys a AVS Addons, when any Addon is enabled.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)
- [Data Collection](#Data-Collection)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.AVS/privateClouds/addons` | [2023-03-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.AVS/privateClouds/addons) |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`arcAddonEnabled`](#parameter-arcaddonenabled) | bool | Define if the ARC Addon will be deployed or not. |
| [`hcxAddonEnabled`](#parameter-hcxaddonenabled) | bool | Define if the HCX Addon will be deployed or not. |
| [`hcxOffer`](#parameter-hcxoffer) | string | The HCX offer. |
| [`privateCloudName`](#parameter-privatecloudname) | string | The name of the AVS private cloud. |
| [`srmAddonEnabled`](#parameter-srmaddonenabled) | bool | Define if the SRM Addon will be deployed or not. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`vcenterResourceId`](#parameter-vcenterresourceid) | string | Required if ARC Addon is enabled. The VMware vCenter resource ID. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`srmLicenseKey`](#parameter-srmlicensekey) | string | License key for SRM, if SRM Addon is enabled. |
| [`srmReplicationServersCount`](#parameter-srmreplicationserverscount) | int | Number of vSphere Replication Servers to be created if SRM Addon is enabled. |

### Parameter: `arcAddonEnabled`

Define if the ARC Addon will be deployed or not.

- Required: Yes
- Type: bool

### Parameter: `hcxAddonEnabled`

Define if the HCX Addon will be deployed or not.

- Required: Yes
- Type: bool

### Parameter: `hcxOffer`

The HCX offer.

- Required: No
- Type: string
- Default: `'VMware MaaS Cloud Provider (Enterprise)'`

### Parameter: `privateCloudName`

The name of the AVS private cloud.

- Required: Yes
- Type: string

### Parameter: `srmAddonEnabled`

Define if the SRM Addon will be deployed or not.

- Required: Yes
- Type: bool

### Parameter: `vcenterResourceId`

Required if ARC Addon is enabled. The VMware vCenter resource ID.

- Required: Yes
- Type: string

### Parameter: `srmLicenseKey`

License key for SRM, if SRM Addon is enabled.

- Required: Yes
- Type: string

### Parameter: `srmReplicationServersCount`

Number of vSphere Replication Servers to be created if SRM Addon is enabled.

- Required: Yes
- Type: int


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `hcxAddonName` | string | The name of the HCX Addon. |
| `resourceGroupName` | string | The resource group of the deployed resource. |

## Cross-referenced modules

_None_

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the [repository](https://aka.ms/avm/telemetry). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
