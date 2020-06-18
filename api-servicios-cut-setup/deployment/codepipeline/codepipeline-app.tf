
variable "env" {
  type = "string"
}

variable "appName" {
  type = "string"
}

variable "appPrefix" {
  type = "string"
}

variable "repositoryApp" {
  type = "string"
}

variable "cBuildRoleBack" {
  type = "string"
}

variable "cBuildRoleFront" {
  type = "string"
}

variable "cPipelineRole" {
  type = "string"
}

variable "cPipelineBucket" {
  type = "string"
}

variable "apiGatewayID" {
  type = "string"
}

variable "apiGatewayRootID" {
  type = "string"
}

variable "lambdaRoleArn" {
  type = "string"
}

variable "kmsKey" {
  type = "string"
}

variable "roleArnGetCodecommit" {
  type = "string"
}

variable "backApiEndpoint" {
  type = "string"
}

variable "cognitoAuthorizeURL" {
  type = "string"
}

variable "cognitoLogoutURL" {
  type = "string"
}

/*
variable "cognitoClientId" {
  type = "string"
}

variable "cognitoRedirectURI" {
  type = "string"
}

variable "cognitoLogoutURI" {
  type = "string"
}
*/

variable "cognitoPoolArn" {
  type = "string"
}

variable "codepipelineRunnerRoleArn" {
  type = "string"
}

variable "codecommitAccount" {
  type = "string"
}

variable "branch" {
  type = "map"
  default = {
    "prod" = "master"
    "dev" = "develop"
    "qa" = "release"
  }
}

################################### parameters ssm ###################################
########## Definicion de parametros requeridos por codebuild front y back ############

resource "aws_ssm_parameter" "defaultParameterBack" {
  name  = "/tgr/${var.env}/${var.appName}/back/default/parameter"
  type  = "String"
  value = "default_value"
  lifecycle {
    ignore_changes = [ "value" ]
  }
  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

resource "aws_ssm_parameter" "defaultParameterFront" {
  name  = "/tgr/${var.env}/${var.appName}/front/default/parameter"
  type  = "String"
  value = "default_value"
  lifecycle {
    ignore_changes = [ "value" ]
  }
  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

resource "aws_ssm_parameter" "wsGrantType" {
  name  = "/tgr/${var.env}/${var.appName}/back/grant-type"
  type  = "String"
  value = "default_value"
  lifecycle {
    ignore_changes = [ "value" ]
  }
  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

resource "aws_ssm_parameter" "wsClientId" {
  name  = "/tgr/${var.env}/${var.appName}/back/client-id"
  type  = "String"
  value = "default_value"
  lifecycle {
    ignore_changes = [ "value" ]
  }
  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

resource "aws_ssm_parameter" "wsClientSecret" {
  name  = "/tgr/${var.env}/${var.appName}/back/client-secret"
  type  = "String"
  value = "default_value"
  lifecycle {
    ignore_changes = [ "value" ]
  }
  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

resource "aws_ssm_parameter" "wsScope" {
  name  = "/tgr/${var.env}/${var.appName}/back/scope"
  type  = "String"
  value = "default_value"
  lifecycle {
    ignore_changes = [ "value" ]
  }
  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

resource "aws_ssm_parameter" "wsHost" {
  name  = "/tgr/${var.env}/${var.appName}/back/host"
  type  = "String"
  value = "default_value"
  lifecycle {
    ignore_changes = [ "value" ]
  }
  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

######################################################################################

resource "aws_codebuild_project" "codebuildBack" {
  name = "${var.appPrefix}-back"
  build_timeout = "15"
  service_role = "${var.cBuildRoleBack}"
  encryption_key = "${var.kmsKey}"
  cache {
    type = "NO_CACHE"
  }
    
  artifacts {
    type = "CODEPIPELINE"
  }
  
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/nodejs:8.11.0"
    type = "LINUX_CONTAINER"

    environment_variable =
                      [
                        {
                          name = "BUILD_ENV"
                          value = "${var.env}"
                        },
                        {
                          name = "BUILD_LAMBDA_ROLE_ARN"
                          value = "${var.lambdaRoleArn}"
                        },
                        {
                          name = "BUILD_API_ID"
                          value = "${var.apiGatewayID}"
                        },
                        {
                          name = "BUILD_API_ROOT_ID"
                          value = "${var.apiGatewayRootID}"
                        },
                        {
                          name = "BUILD_WST_GRANT_TYPE"
                          value = "/tgr/${var.env}/${var.appName}/back/grant-type"
                          type = "PARAMETER_STORE"
                        },
                        {
                          name = "BUILD_COGNITO_POOL_ARN"
                          value = "${var.cognitoPoolArn}"
                        },
                        {
                          name = "BUILD_WST_CLIENT_ID"
                          value = "/tgr/${var.env}/${var.appName}/back/client-id"
                          type = "PARAMETER_STORE"
                        },
                        {
                          name = "BUILD_WST_CLIENT_SECRET"
                          value = "/tgr/${var.env}/${var.appName}/back/client-secret"
                          type = "PARAMETER_STORE"
                        },
                        {
                          name = "BUILD_WST_SCOPE"
                          value = "/tgr/${var.env}/${var.appName}/back/scope"
                          type = "PARAMETER_STORE"
                        },
                        {
                          name = "BUILD_WST_HOST"
                          value = "/tgr/${var.env}/${var.appName}/back/host"
                          type = "PARAMETER_STORE"
                        }
                      ]

  }
  source {
    type = "CODEPIPELINE"
    buildspec = "back/buildspec.yml"
  }
  
  tags = {
    Application = "${var.appName}"
	Env = "${var.env}"
  }

}

resource "aws_codepipeline" "codepipelineApp" {
  name = "${var.appPrefix}"
  role_arn = "${var.cPipelineRole}"

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      role_arn = "${var.roleArnGetCodecommit}"
      output_artifacts = ["Source"]
      
      configuration {
        RepositoryName = "${var.repositoryApp}"
        BranchName = "${var.branch[var.env]}"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build-Back"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["Source"]

      configuration {
        ProjectName = "${aws_codebuild_project.codebuildBack.name}"
      }
    }
  }

  artifact_store {
	location       = "${var.cPipelineBucket}"
	type           = "S3"
	encryption_key = {
      id = "${var.kmsKey}"
      type = "KMS"
	}
  }
}

data "template_file" "sourceEventTemplate" {
  template = "${file("deployment/codepipeline/steps-source-event.json")}"
  vars {
    repositoryArn = "arn:aws:codecommit:us-east-1:${var.codecommitAccount}:${var.repositoryApp}"
    branchName = "${var.branch[var.env]}"
  }
}

resource "aws_cloudwatch_event_rule" "sourceEvent" {
  name = "${var.appPrefix}-impl-source-change"
  event_pattern = "${data.template_file.sourceEventTemplate.rendered}"
}

resource "aws_cloudwatch_event_target" "stepsSourceEventTarget" {
  rule = "${aws_cloudwatch_event_rule.sourceEvent.name}"
  target_id = "StartCodepipeline"
  role_arn = "${var.codepipelineRunnerRoleArn}"
  arn = "${aws_codepipeline.codepipelineApp.arn}"
}
