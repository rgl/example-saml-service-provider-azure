# see https://github.com/hashicorp/terraform
terraform {
  required_version = "1.3.9"
  required_providers {
    # see https://github.com/hashicorp/terraform-provider-random
    # see https://registry.terraform.io/providers/hashicorp/random
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    # see https://github.com/hashicorp/terraform-provider-time
    # see https://registry.terraform.io/providers/hashicorp/time
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
    # see https://github.com/terraform-providers/terraform-provider-azuread
    # see https://registry.terraform.io/providers/hashicorp/azuread
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.34.1"
    }
  }
}

# see https://github.com/terraform-providers/terraform-provider-azuread
provider "azuread" {
}
