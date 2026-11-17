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
    web  = "10.20.1.0/24"
    data = "10.20.2.0/24"
  }

  tags = local.tags
}

module "webserver" {
  source = "../../modules/webserver"

  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.network.subnet_ids["web"]
  nsg_name            = module.network.nsg_names["web"]
  instances           = var.web_instances
  ssh_public_key      = var.ssh_public_key
  tags                = local.tags
}
