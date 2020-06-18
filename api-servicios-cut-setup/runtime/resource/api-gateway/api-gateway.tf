variable "env" {
  type = "string"
}

variable "appPrefix" {
  type = "string"
}

variable "apiKnownName" {
  type = "string"
}

variable "apiDomainName" {
  type = "string"
}

data "aws_region" "getRegionData" {}

resource "aws_api_gateway_rest_api" "apigatewayBack" {
  name = "${var.appPrefix}-back"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }

}

locals {
  #base_path = "${replace(var.apiKnownName,"api-","")}"
  base_path = "${var.apiKnownName}"
}

resource "aws_api_gateway_base_path_mapping" "path-mapping-api-tgr" {
  api_id = "${aws_api_gateway_rest_api.apigatewayBack.id}"
  #stage_name  = "${replace(var.apiVersion, ".", "-")}"
  #base_path = "${var.env == "prod"? var.apiKnownName : local.base_path}"
  base_path = "${local.base_path}"
  domain_name = "${var.apiDomainName}"
}

output "apigatewayID" {
  value = "${aws_api_gateway_rest_api.apigatewayBack.id}"
}

output "apigatewayRootID" {
  value = "${aws_api_gateway_rest_api.apigatewayBack.root_resource_id}"
}

output "apigatewayEndpoint" {
  value = "https://${aws_api_gateway_rest_api.apigatewayBack.id}.execute-api.${data.aws_region.getRegionData.name}.amazonaws.com/${var.env}"
}