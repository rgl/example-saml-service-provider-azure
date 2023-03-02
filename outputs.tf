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

output "saml_entity_id" {
  value = local.saml_entity_id
}

output "saml_metadata_url" {
  value = saml_metadata.example.url
}

output "user_access_url" {
  value = local.user_access_url
}
