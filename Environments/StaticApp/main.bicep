// param location string = 'westeurope'
// param location_suffix string = 'demo1'
// param location_suffix string = 'demo2'

param location string = resourceGroup().location
param vnetNamevar string = 'vnet${uniqueString(resourceGroup().id)}'
param vnetAdressSpace string = '10.${subnetAddressPrefix}.0.0/16'
param subnetWebAppName string = 'subnetwebapp${uniqueString(resourceGroup().id)}'
param subnetWebAppAdressSpace string = '10.${subnetAddressPrefix}.1.0/24'
param staticwebname string = 'webapp${uniqueString(resourceGroup().id)}'
param appInsights string = 'appinsight${uniqueString(resourceGroup().id)}'
param storageaccountname string = 'stg${uniqueString(resourceGroup().id)}'
param managedIdentityname string = 'mi${uniqueString(resourceGroup().id)}'
param keyvaultname string = 'kaevault${uniqueString(resourceGroup().id)}'

resource vnetName 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetNamevar
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAdressSpace
      ]
    }
    subnets: [     
      {
        name: subnetWebAppName
        properties: {
          addressPrefix: subnetWebAppAdressSpace
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource vnetName_subnetWebAppName 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnetName
  name: subnetWebAppName
  properties: {
    addressPrefix: subnetWebAppAdressSpace
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource appInsightsComponents 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsights
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageaccountname
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyvaultname
  location: location
  
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId

    accessPolicies: []
    softDeleteRetentionInDays: 7
  }
}


// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
//   name: 'name'
//   properties: {
//     roleDefinitionId: 'roleDefinitionId'
//     principalId: 'principalId'
//     principalType: 'ServicePrincipal'
//   }
// }

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityname
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: 'name'
  properties: {
    roleDefinitionId: 'roleDefinitionId'
    principalId: 'principalId'
    principalType: 'ServicePrincipal'
  }
}

resource symbolicname 'Microsoft.Web/staticSites@2022-09-01' = {
  name: staticwebname
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    repositoryUrl: 'https://dev.azure.com/damayantibhuyan/customerPOCs/_git/StaticWebApp'
    branch: 'master'
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    provider: 'DevOps'
    enterpriseGradeCdnStatus: 'Disabled'
  }
}
