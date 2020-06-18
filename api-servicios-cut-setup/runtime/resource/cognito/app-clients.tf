variable "appPrefix" {
  type = "string"
}

variable "cognitoPoolID" {
  type = "string"
}

variable "cloudfrontAlias" {
  type = "string"
}

variable "cognitoProviders" {
  type = "list"
}

variable "cognitoReadAttributes" {
  type = "list"
}

/*
resource "aws_cognito_user_pool_client" "appClient" {
  name = "${var.appPrefix}"

  user_pool_id = "${var.cognitoPoolID}"

  callback_urls = [
    "https://${var.cloudfrontAlias}/login"
  ]

  logout_urls = [
    "https://${var.cloudfrontAlias}/logout"
  ]

  allowed_oauth_flows = [
    "implicit"
  ]

  allowed_oauth_scopes = [
    "email",
    "openid",
    "profile"
  ]

  allowed_oauth_flows_user_pool_client = true

  supported_identity_providers = "${var.cognitoProviders}"

  #read_attributes = "${var.cognito-read-attributes}"
  #[
  #  "custom:clave-unica:run",
  #  "custom:clave-unica:name"]
}
*/

resource "aws_cognito_resource_server" "resource" {
  identifier = "${var.appPrefix}"
  name = "${var.appPrefix}"
  user_pool_id = "${var.cognitoPoolID}"

  scope = [
    {
      scope_name = "all"
      scope_description = "Tiene permisos para ingresar solicitudes y consultarlas"
    }
  ]
}

resource "aws_cognito_user_pool_client" "all" {
  name = "${var.appPrefix}-all"

  user_pool_id = "${var.cognitoPoolID}"

  generate_secret = true
  # explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = [
    "client_credentials"]
  depends_on = [
    "aws_cognito_resource_server.resource"
  ]

  allowed_oauth_scopes = [
    "${aws_cognito_resource_server.resource.identifier}/all",
  ]
  supported_identity_providers = [
    "COGNITO"]
}

/*
output "cognitoClientID" {
  value = "${aws_cognito_user_pool_client.appClient.id}"
}

output "cognitoRedirectUri" {
  value = "${aws_cognito_user_pool_client.appClient.callback_urls[0]}"
}

output "cognitoLogoutUri" {
  value = "${aws_cognito_user_pool_client.appClient.logout_urls[0]}"
}
*/