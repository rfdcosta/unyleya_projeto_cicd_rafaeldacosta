terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
# Configure the Microsoft Azure Provide
provider "azurerm" {
  features {}  
}
resource "azurerm_resource_group" "resource_rafael" {
  name     = "rafael-aks"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "rafael-kub-aks" {
  name                = "rafael-kub-aks"
  location            = azurerm_resource_group.resource_rafael.location
  resource_group_name = azurerm_resource_group.resource_rafael.name
  dns_prefix          = "rafaeldns"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
    
  }

  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_container_registry" "acr" {
  name                = "rafaelacr"
  resource_group_name = azurerm_resource_group.resource_rafael.name
  location            = azurerm_resource_group.resource_rafael.location
  sku                 = "Premium"
  admin_enabled       = false
}
resource "azurerm_role_assignment" "acr-role" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id = azurerm_kubernetes_cluster.rafael-kub-aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}