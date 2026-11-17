terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

# Azure Virtual Desktop control plane: host pool, desktop application group, workspace.
# This is the part of AVD that Terraform manages best. Session host VMs are a stretch lab (Day 33).

resource "azurerm_virtual_desktop_host_pool" "this" {
  name                     = "hp-${var.name}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  friendly_name            = var.friendly_name
  description              = "Managed by Terraform"
  type                     = "Pooled"
  load_balancer_type       = var.load_balancer_type
  maximum_sessions_allowed = var.max_sessions_per_host
  preferred_app_group_type = "Desktop"
  validate_environment     = false
  start_vm_on_connect      = true
  tags                     = var.tags
}

# Registration token that session hosts use to join the pool. Treat it as a secret.
resource "azurerm_virtual_desktop_host_pool_registration_info" "this" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = var.registration_expiration_date

  # The caller passes a moving timestamp; do not churn the token on every plan.
  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                = "dag-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.this.id
  friendly_name       = "${var.friendly_name} desktop"
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace" "this" {
  name                = "ws-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = var.friendly_name
  description         = "Workspace for ${var.friendly_name}"
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "this" {
  workspace_id         = azurerm_virtual_desktop_workspace.this.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}
