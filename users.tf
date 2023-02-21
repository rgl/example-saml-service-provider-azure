# see https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "alice" {
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

# see https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "bob" {
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

# see https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "carol" {
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/user
resource "azuread_user" "alice" {
  given_name          = "Alice"
  surname             = "Doe"
  display_name        = "Alice Doe"
  user_principal_name = "${var.prefix}-alice.doe@${data.azuread_domains.current.domains.0.domain_name}"
  mail                = "${var.prefix}-alice.doe@${data.azuread_domains.current.domains.0.domain_name}"
  usage_location      = "PT"
  password            = random_password.alice.result
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/user
resource "azuread_user" "bob" {
  given_name          = "Bob"
  surname             = "Doe"
  display_name        = "Bob Doe"
  user_principal_name = "${var.prefix}-bob.doe@${data.azuread_domains.current.domains.0.domain_name}"
  mail                = "${var.prefix}-bob.doe@${data.azuread_domains.current.domains.0.domain_name}"
  usage_location      = "PT"
  password            = random_password.bob.result
}

# see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/user
resource "azuread_user" "carol" {
  given_name          = "Carol"
  surname             = "Doe"
  display_name        = "Carol Doe"
  user_principal_name = "${var.prefix}-carol.doe@${data.azuread_domains.current.domains.0.domain_name}"
  mail                = "${var.prefix}-carol.doe@${data.azuread_domains.current.domains.0.domain_name}"
  usage_location      = "PT"
  password            = random_password.carol.result
}
