terraform {
  backend "azurerm" {}
  required_version = ">= 0.15.4"
  required_providers {
    azurerm = {
      version = ">=2.0.0"
    }
    random = {
      version = ">= 2.2.0"
    }
    azuread = {
      version = ">=1.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}
provider "random" {}
provider "azuread" {}
provider "azuread" {
  alias         = "otp_sub"
  client_id     = var.otp_client_id
  client_secret = var.otp_client_secret
  tenant_id     = var.opt_tenant_id
}
