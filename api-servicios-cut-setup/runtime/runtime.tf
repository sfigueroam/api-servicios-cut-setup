variable "env" {
  type = "string"
}

variable "appPrefix" {
  type = "string"
}

variable "appName" {
  type = "string"
}

variable "appFrontSubdomain" {
  type = "string"
}

variable "appFrontDomain" {
  type = "string"
}

variable "route53ZoneId" {
  type = "string"
}

variable "cognitoReadAttributes" {
  type = "list"
}

variable "cognitoPoolId" {
  type = "string"
}

variable "cognitoProviders" {
  type = "list"
}

variable "acmCertificateArn" {
  type = "string"
}

variable "apiDomainName" {
  type = "string"
}

variable "apiKnownName" {
  type = "string"
}

module "runtimeApiGateway" {
  source = "./resource/api-gateway"
  appPrefix = "${var.appPrefix}"
  env = "${var.env}"
  apiDomainName = "${var.apiDomainName}"
  apiKnownName = "${var.apiKnownName}"
}

module "runtimePermission" {
  source = "./permission"
  env = "${var.env}"
  appName = "${var.appName}"
  appPrefix = "${var.appPrefix}"
}

module "runtimeCognitoAppClients" {
  source = "./resource/cognito"
  appPrefix = "${var.appPrefix}"
  cloudfrontAlias = "${var.appFrontSubdomain}.${var.appFrontDomain}"
  cognitoReadAttributes = ["${var.cognitoReadAttributes}"]
  cognitoPoolID = "${var.cognitoPoolId}"
  cognitoProviders = ["${var.cognitoProviders}"]
}

output "lambdaRoleArn" {
  value = "${module.runtimePermission.lambdaRoleArn}"
}

output "apiGatewayID" {
  value = "${module.runtimeApiGateway.apigatewayID}"
}

output "apiGatewayRootID" {
  value = "${module.runtimeApiGateway.apigatewayRootID}"
}

output "apigatewayEndpoint" {
  value = "${module.runtimeApiGateway.apigatewayEndpoint}"
}

/*
output "cognitoClientID" {
  value = "${module.runtimeCognitoAppClients.cognitoClientID}"
}

output "cognitoRedirectUri" {
  value = "${module.runtimeCognitoAppClients.cognitoRedirectUri}"
}

output "cognitoLogoutUri" {
  value = "${module.runtimeCognitoAppClients.cognitoLogoutUri}"
}
*/