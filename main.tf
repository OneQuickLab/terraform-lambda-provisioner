# ----------------------------------------------------------------------------------------------------------------------
# SETUP PROVIDER
# ----------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "ca-central-1"
}

terraform {
  required_providers {
    archive = "~> 1.3"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# PREPARE DEPLOYMENT PACKAGES
# A deployment package is a ZIP archive that contains your function code and dependencies.
# ----------------------------------------------------------------------------------------------------------------------

data "archive_file" "provisioner_get_templates" {
  type        = "zip"
  source_file = "../${path.module}/src/provisionerGetTemplates.py"
  output_path = "../${path.module}/src/provisionerGetTemplates.py.zip"
}

data "archive_file" "provisioner_create_ec2" {
  type        = "zip"
  source_file = "../${path.module}/src/provisionerCreateEc2.py"
  output_path = "../${path.module}/src/provisionerCreateEc2.py.zip"
}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY LAMBDA FUNCTIONS
# ----------------------------------------------------------------------------------------------------------------------

module "lambda_provisioner_get_templates" {
  source  = "mineiros-io/lambda-function/aws"
  version = "~> 0.5.0"

  function_name = "provisionerGetTemplates_v2"
  description   = "AWS Lambda Provisioner - Get Templates"
  filename      = data.archive_file.provisioner_get_templates.output_path
  runtime       = "python3.8"
  handler       = "main.lambda_handler"
  timeout       = 30
  memory_size   = 128

  role_arn = module.iam_role_provisioner_get_templates.role.arn

  module_tags = {
    Environment = "Dev"
  }
}

module "lambda_provisioner_create_ec2" {
  source  = "mineiros-io/lambda-function/aws"
  version = "~> 0.5.0"

  function_name = "provisionerCreateEc2_v2"
  description   = "AWS Lambda Provisioner - Create EC2 Instance"
  filename      = data.archive_file.provisioner_create_ec2.output_path
  runtime       = "python3.8"
  handler       = "main.lambda_handler"
  timeout       = 30
  memory_size   = 128

  role_arn = module.iam_role_provisioner_create_ec2.role.arn

  module_tags = {
    Environment = "Dev"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE IAM POLICIES
# ----------------------------------------------------------------------------------------------------------------------

module "iam_policy_provisioner_get_templates" {
  source  = "mineiros-io/iam-policy/aws"
  version = "~> 0.5.0"

  name = "ProvisionerGetTemplatesPolicy"

  policy_statements = [
    {
      sid = "ProvisionerGetTemplatesS3GetObject"

      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["arn:aws:s3:::*"]
    },
    {
      sid = "ProvisionerGetTemplatesCreateLogGroup"

      effect    = "Allow"
      actions   = ["logs:CreateLogGroup"]
      resources = ["arn:aws:logs:ca-central-1:176399646443:*"]
    },
    {
      sid = "ProvisionerGetTemplatesPutLogEvents"

      effect    = "Allow"
      actions   = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resources = ["arn:aws:logs:ca-central-1:176399646443:log-group:/aws/lambda/provisionerGetTemplates:*"]
    }
  ]
}

module "iam_policy_provisioner_create_ec2" {
  source  = "mineiros-io/iam-policy/aws"
  version = "~> 0.5.0"

  name = "ProvisionerCreateEc2Policy"

  policy_statements = [
    {
      sid = "ProvisionerCreateEc2CreateLogGroup"

      effect    = "Allow"
      actions   = ["logs:CreateLogGroup"]
      resources = ["arn:aws:logs:ca-central-1:176399646443:*"]
    },
    {
      sid = "ProvisionerCreateEc2PutLogEvents"

      effect    = "Allow"
      actions   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ]
      resources = ["arn:aws:logs:ca-central-1:176399646443:log-group:/aws/lambda/provisionerCreateEc2:*"]
    },
    {
      sid = "ProvisionerCreateEc2CreateTags"

      effect     = "Allow"
      actions    = ["ec2:CreateTags"]
      resources  = ["arn:aws:ec2:region:account:176399646443/*"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "ec2:CreateAction"
          values   = [ "RunInstances" ]
        }
      ]
    }
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE IAM ROLES
# ----------------------------------------------------------------------------------------------------------------------

module "iam_role_provisioner_get_templates" {
  source  = "mineiros-io/iam-role/aws"
  version = "~> 0.6.0"

  name = "ProvisionerGetTemplatesRole"

  assume_role_principals = [
    {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  ]

  policy_arns = [
    module.iam_policy_provisioner_get_templates.policy.arn
  ]

  tags = {
    Environment = "Dev"
  }
}

module "iam_role_provisioner_create_ec2" {
  source  = "mineiros-io/iam-role/aws"
  version = "~> 0.6.0"

  name = "ProvisionerCreateEc2Role"

  assume_role_principals = [
    {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  ]

  policy_arns = [
    module.iam_policy_provisioner_create_ec2.policy.arn
  ]

  tags = {
    Environment = "Dev"
  }
}