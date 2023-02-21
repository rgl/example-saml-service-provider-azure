output "alice_email" {
  value = azuread_user.alice.mail
}

output "alice_password" {
  sensitive = true
  value     = azuread_user.alice.password
}

output "bob_email" {
  value = azuread_user.bob.mail
}

output "bob_password" {
  sensitive = true
  value     = azuread_user.bob.password
}

output "carol_email" {
  value = azuread_user.carol.mail
}

output "carol_password" {
  sensitive = true
  value     = azuread_user.carol.password
}

output "application_id" {
  value = azuread_application.example.application_id
}

output "service_principal_id" {
  value = azuread_service_principal.example.id
}

output "saml_metadata_url" {
  # NB unfortunately, azuread_service_principal.example.saml_metadata_url is
  #    always empty, so we have to construct the value manually. this will
  #    probably break in the future when the azure implementation changes
  #    this... but for now it works.
  # e.g. https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/federationmetadata/2007-06/federationmetadata.xml?appid=00000000-0000-0000-0000-000000000001
  value = "https://login.microsoftonline.com/${azuread_service_principal.example.application_tenant_id}/federationmetadata/2007-06/federationmetadata.xml?appid=${azuread_service_principal.example.application_id}"
}
