terraform {
  //backend "azurerm" {}

  required_version = ">= 1.0.4"
  required_providers {
    azurerm = ">=2.0.0"
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  subscription_id = var.log_analytics_subscription_id
  alias           = "log-analytics-subscription"
  features {}
}
