# AVS Private Cloud Authorizations `[Microsoft.AVS/privateClouds/authorizations]`

This module creates a connection between AVS SDDC and a vNet, when Networking Connectivity is enabled.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)
- [Data Collection](#Data-Collection)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.AVS/privateClouds/authorizations` | [2023-03-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.AVS/privateClouds/authorizations) |
| `Microsoft.Network/connections` | [2023-09-01](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/connections) |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authKeyName`](#parameter-authkeyname) | string | The name of the Authorization Key. |
| [`connectionName`](#parameter-connectionname) | string | The name of the connection. |
| [`gatewayName`](#parameter-gatewayname) | string | The name of the customer ExpressRoute Virtual Network Gateway of the Hub vNet. |
| [`location`](#parameter-location) | string | Location of the resources. |
| [`privateCloudName`](#parameter-privatecloudname) | string | The name of the AVS private cloud. |

### Parameter: `authKeyName`

The name of the Authorization Key.

- Required: Yes
- Type: string

### Parameter: `connectionName`

The name of the connection.

- Required: Yes
- Type: string

### Parameter: `gatewayName`

The name of the customer ExpressRoute Virtual Network Gateway of the Hub vNet.

- Required: Yes
- Type: string

### Parameter: `location`

Location of the resources.

- Required: Yes
- Type: string

### Parameter: `privateCloudName`

The name of the AVS private cloud.

- Required: Yes
- Type: string


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `connectionId` | string | The Connection ID. |
| `connectionName` | string | The name of the Connection. |
| `expressRouteAuthKey` | string | The Authorization Key. |
| `name` | string | The name of the Authorization Key. |
| `resourceGroupName` | string | The resource group of the deployed resource. |
| `resourceId` | string | The ResourceId of the Authorization Key. |

## Cross-referenced modules

_None_

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the [repository](https://aka.ms/avm/telemetry). There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
