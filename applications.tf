locals {
  saml_entity_id = "urn:example:${var.prefix}"

  # NB unfortunately, azuread_service_principal.example.saml_metadata_url is
  #    always empty, so we have to construct the value manually. this will
  #    probably break in the future when the azure implementation changes
  #    this... but for now it works.
  # e.g. https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/federationmetadata/2007-06/federationmetadata.xml?appid=00000000-0000-0000-0000-000000000001
  saml_metadata_url = "https://login.microsoftonline.com/${azuread_service_principal.example.application_tenant_id}/federationmetadata/2007-06/federationmetadata.xml?appid=${azuread_service_principal.example.application_id}"
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "example" {
  display_name     = var.prefix
  owners           = [data.azuread_client_config.current.object_id]
  logo_image       = filebase64("logo.png")
  sign_in_audience = "AzureADMyOrg"
  identifier_uris  = [local.saml_entity_id]
  web {
    homepage_url = "http://localhost:8000"
    redirect_uris = [
      "http://localhost:8000/saml/acs",
    ]
  }
  app_role {
    id                   = uuidv5("url", "urn:administrator")
    value                = "administrator"
    description          = "Administrator"
    display_name         = "Administrator"
    allowed_member_types = ["User"]
  }
  app_role {
    id                   = uuidv5("url", "urn:author")
    value                = "author"
    description          = "Author"
    display_name         = "Author"
    allowed_member_types = ["User"]
  }
  app_role {
    id                   = uuidv5("url", "urn:reader")
    value                = "reader"
    description          = "Reader"
    display_name         = "Reader"
    allowed_member_types = ["User"]
  }
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal
resource "azuread_service_principal" "example" {
  application_id                = azuread_application.example.application_id
  owners                        = [data.azuread_client_config.current.object_id]
  app_role_assignment_required  = true
  preferred_single_sign_on_mode = "saml"
  notes                         = "example notes"
  tags = [
    "WindowsAzureActiveDirectoryCustomSingleSignOnApplication", # custom_single_sign_on
    "WindowsAzureActiveDirectoryIntegratedApp",                 # enterprise
  ]
  saml_single_sign_on {
    relay_state = "http://localhost:8000"
  }
}

# see https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating
resource "time_rotating" "example" {
  rotation_years = 3
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_token_signing_certificate
# see https://github.com/hashicorp/terraform-provider-azuread/pull/968
resource "azuread_service_principal_token_signing_certificate" "example" {
  service_principal_id = azuread_service_principal.example.id
  end_date             = time_rotating.example.rotation_rfc3339
  display_name         = "CN=${azuread_application.example.display_name} SSO Certificate" # (default: Microsoft Azure Federated SSO Certificate)
  # TODO find a non provisioner way of doing this.
  provisioner "local-exec" {
    # NB this is in a single line to make it work in a linux or windows host.
    command = "az ad sp update --id ${self.service_principal_id} --set preferredTokenSigningKeyThumbprint=${self.thumbprint}"
  }
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/claims_mapping_policy
# see https://learn.microsoft.com/en-us/graph/api/resources/claimsmappingpolicy?view=graph-rest-1.0
resource "azuread_claims_mapping_policy" "example" {
  display_name = azuread_application.example.display_name
  definition = [
    jsonencode(
      {
        ClaimsMappingPolicy = {
          Version              = 1
          IncludeBasicClaimSet = "true"
          ClaimsSchema = [
            {
              SamlClaimType = "urn:example:email"
              Source        = "user"
              ID            = "mail"
            },
            {
              SamlClaimType = "urn:example"
              Value         = "example"
            },
          ]
        }
      }
    ),
  ]
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_claims_mapping_policy_assignment
resource "azuread_service_principal_claims_mapping_policy_assignment" "example" {
  claims_mapping_policy_id = azuread_claims_mapping_policy.example.id
  service_principal_id     = azuread_service_principal.example.id
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment
resource "azuread_app_role_assignment" "alice" {
  app_role_id         = azuread_application.example.app_role_ids["administrator"]
  resource_object_id  = azuread_service_principal.example.object_id
  principal_object_id = azuread_user.alice.object_id
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment
resource "azuread_app_role_assignment" "bob" {
  app_role_id         = azuread_application.example.app_role_ids["author"]
  resource_object_id  = azuread_service_principal.example.object_id
  principal_object_id = azuread_user.bob.object_id
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment
resource "azuread_app_role_assignment" "carol" {
  app_role_id         = azuread_application.example.app_role_ids["reader"]
  resource_object_id  = azuread_service_principal.example.object_id
  principal_object_id = azuread_user.carol.object_id
}
