# About

[![Lint](https://github.com/rgl/example-saml-service-provider-azure/actions/workflows/lint.yml/badge.svg)](https://github.com/rgl/example-saml-service-provider-azure/actions/workflows/lint.yml)

Azure AD (AAD) configuration for the [example-saml-service-provider](https://github.com/rgl/example-saml-service-provider).

This will use [terraform](https://www.terraform.io/) to create the [Users](users.tf), [Application, Application Roles, Enterprise Application (aka Service Principal)](applications.tf) to use the `example-saml-service-provider` web application.

You can test this in a [Free Microsoft 365 E5 instant sandbox](https://developer.microsoft.com/en-us/microsoft-365/dev-program).

# Usage

Install the required tools:

* [terraform](https://github.com/hashicorp/terraform).
* [azure-cli](https://github.com/Azure/azure-cli).
* [go](https://github.com/golang/go).

Login into Azure:

```bash
az login --allow-no-subscriptions
```

Ensure the expected account is set as default:

```bash
az account show
az account list
az account set --subscription=<tenantId or id>
az account show
```

Initialize terraform:

```bash
make terraform-init
```

Launch the example:

```bash
make terraform-plan-apply
```

Show the created Application and Enterprise Application (aka Service Principal):

```bash
az ad app show --id $(terraform output -raw application_id)
az ad sp show --id $(terraform output -raw service_principal_id)
# see https://learn.microsoft.com/en-us/graph/api/application-get?view=graph-rest-1.0&tabs=http
az rest \
  --method GET \
  --uri "https://graph.microsoft.com/v1.0/applications(appId='$(terraform output -raw application_id)')"
# see https://learn.microsoft.com/en-us/graph/api/serviceprincipal-get?view=graph-rest-1.0&tabs=http
az rest \
  --method GET \
  --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$(terraform output -raw service_principal_id)"
```

Show all the Applications and Enterprise Applications (aka Service Principals):

```bash
az ad app list
az ad sp list
# see https://learn.microsoft.com/en-us/graph/api/application-list?view=graph-rest-1.0&tabs=http
az rest --method GET --uri https://graph.microsoft.com/v1.0/applications
# see https://learn.microsoft.com/en-us/graph/api/serviceprincipal-list?view=graph-rest-1.0&tabs=http
az rest --method GET --uri https://graph.microsoft.com/v1.0/servicePrincipals
```

Show the `Alice` credentials:

```bash
terraform output -raw alice_email
terraform output -raw alice_password
```

Clone the example SAML Service Provider application repository, build,
and execute it:

```bash
git clone https://github.com/rgl/example-saml-service-provider
cd example-saml-service-provider
make build
EXAMPLE_ENTITY_ID="$(cd .. && terraform output -raw saml_entity_id)"
EXAMPLE_IDP_METADATA="$(cd .. && terraform output -raw saml_metadata_url)"
./example-saml-service-provider \
  --entity-id $EXAMPLE_ENTITY_ID \
  --idp-metadata $EXAMPLE_IDP_METADATA
```

Open this example SAML Service Provider page, and click the `login` link to go
through the authentication flow using the `Alice` credentials:

http://localhost:8000

**NB** Alternatively, you can initiate a user login from the IDP side at the URL
given by:

```bash
terraform output -raw user_access_url
```

After a successful authentication, you should see a list of SAML Claims,
similar to:

| Name                                                                  | Value                                                                                 |
|-----------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| `http://schemas.microsoft.com/claims/authnmethodsreferences`          | `http://schemas.microsoft.com/ws/2008/06/identity/authenticationmethod/password`      |
| `http://schemas.microsoft.com/identity/claims/displayname`            | `Alice Doe`                                                                           |
| `http://schemas.microsoft.com/identity/claims/identityprovider`       | `https://sts.windows.net/00000000-0000-0000-0000-000000000000/`                       |
| `http://schemas.microsoft.com/identity/claims/objectidentifier`       | `00000000-0000-0000-0000-000000000000`                                                |
| `http://schemas.microsoft.com/identity/claims/tenantid`               | `00000000-0000-0000-0000-000000000000`                                                |
| `http://schemas.microsoft.com/ws/2008/06/identity/claims/role`        | `administrator`                                                                       |
| `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname`     | `Alice`                                                                               |
| `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name`          | `example-saml-service-provider-alice.doe@example.com`                                 |
| `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname`       | `Doe`                                                                                 |
| `SessionIndex`                                                        | `_00000000-0000-0000-0000-000000000000`                                               |
| `urn:example`                                                         | `example`                                                                             |
| `urn:example:email`                                                   | `example-saml-service-provider-alice.doe@example.com`                                 |

**NB** When the user uses multi-factor-authentication (MFA) to login, the following claim is also included:

| Name                                                                  | Value                                                                                 |
|-----------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| `http://schemas.microsoft.com/claims/authnmethodsreferences`          | `http://schemas.microsoft.com/claims/multipleauthn`                                   |

And destroy everything:

```bash
make terraform-destroy
```
