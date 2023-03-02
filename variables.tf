# NB this name must be unique within the Azure subscription.
#    all the other names must be unique within this resource group.
variable "prefix" {
  default = "example-saml-service-provider"
  type    = string
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config
data "azuread_client_config" "current" {
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/domains
data "azuread_domains" "current" {
  only_initial = true
}
