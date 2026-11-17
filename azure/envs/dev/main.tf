terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }

  # Remote state in Azure Storage. Fill in the values printed by azure/bootstrap, or pass them with:
  #   terraform init -backend-config="storage_account_name=<name>"
  backend "azurerm" {
    resource_group_name = "rg-tfstate"
    container_name      = "tfstate"
    key                 = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

locals {
  name = "${var.project}-${var.environment}"

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = local.tags
}

module "network" {
  source = "../../modules/network"

  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.20.0.0/16"]

  subnets = {
    avd = "10.20.1.0/24"
    app = "10.20.2.0/24"
  }

  tags = local.tags
}

module "avd" {
  source = "../../modules/avd"

  name                         = local.name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.this.name
  friendly_name                = var.avd_friendly_name
  max_sessions_per_host        = var.avd_max_sessions_per_host
  registration_expiration_date = timeadd(plantimestamp(), "48h")
  tags                         = local.tags
}
