# ----------------------------------------------------------------------------------------------------------------------
# SETUP PROVIDER
# ----------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
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

data "archive_file" "lambda_provisioner_get_templates" {
  type        = "zip"
  source_file = "${path.module}/src/lambdaProvisionerGetTemplates.py"
  output_path = "${path.module}/src/lambdaProvisionerGetTemplates.py.zip"
}

data "archive_file" "lambda_provisioner_create_ec2" {
  type        = "zip"
  source_file = "${path.module}/src/lambdaProvisionerCreateEc2.py"
  output_path = "${path.module}/src/lambdaProvisionerCreateEc2.py.zip"
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE A TEMPORARY SSH KEY PAIR
# ----------------------------------------------------------------------------------------------------------------------

module "lambda_provisioner_keypair" {
  source  = "cloudposse/key-pair/aws"
  version = "0.18.2"

  name                  = var.provisioner_keypair
  ssh_public_key_path   = "${path.module}/src/secrets"
  generate_ssh_key      = "true"
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE S3 BUCKET AND UPLOAD TEMPLATES
# ----------------------------------------------------------------------------------------------------------------------

module "lambda_provisioner_templates" {
  source  = "mineiros-io/s3-bucket/aws"
  version = "~> 0.6.0"

  bucket = var.templates_bucket_name

  versioning = true

  tags = {
    Name = var.templates_bucket_name
  }
}

resource "aws_s3_bucket_object" "object" {

  source = "${path.module}/src/templates.json"
  bucket = module.lambda_provisioner_templates.id
  key    = "templates.json"
  acl    = "private"

}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY LAMBDA FUNCTIONS
# ----------------------------------------------------------------------------------------------------------------------

module "lambda_lambda_provisioner_get_templates" {
  source  = "mineiros-io/lambda-function/aws"
  version = "~> 0.5.0"

  function_name = "lambdaProvisionerGetTemplates"
  description   = "AWS Lambda Provisioner - Get Templates"
  filename      = data.archive_file.lambda_provisioner_get_templates.output_path
  runtime       = "python3.8"
  handler       = "lambdaProvisionerGetTemplates.lambda_handler"
  timeout       = 30
  memory_size   = 128

  role_arn = module.iam_role_lambda_provisioner_get_templates.role.arn

  module_tags = {
    Environment = var.provisioner_environment
  }
}

module "lambda_lambda_provisioner_create_ec2" {
  source  = "mineiros-io/lambda-function/aws"
  version = "~> 0.5.0"

  function_name = "lambdaProvisionerCreateEc2"
  description   = "AWS Lambda Provisioner - Create EC2 Instance"
  filename      = data.archive_file.lambda_provisioner_create_ec2.output_path
  runtime       = "python3.8"
  handler       = "lambdaProvisionerCreateEc2.lambda_handler"
  timeout       = 30
  memory_size   = 128

  role_arn = module.iam_role_lambda_provisioner_create_ec2.role.arn

  module_tags = {
    Environment = var.provisioner_environment
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE IAM POLICIES
# ----------------------------------------------------------------------------------------------------------------------

module "iam_policy_lambda_provisioner_get_templates" {
  source  = "mineiros-io/iam-policy/aws"
  version = "~> 0.5.0"

  name = "LambdaProvisionerGetTemplatesPolicy"

  policy_statements = [
    {
      sid = "LambdaProvisionerGetTemplatesS3GetObject"

      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["arn:aws:s3:::*"]
    },
    {
      sid = "LambdaProvisionerGetTemplatesCreateLogGroup"

      effect    = "Allow"
      actions   = ["logs:CreateLogGroup"]
      resources = ["arn:aws:logs:${var.aws_region}:${var.aws_account}:*"]
    },
    {
      sid = "LambdaProvisionerGetTemplatesPutLogEvents"

      effect    = "Allow"
      actions   = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resources = ["arn:aws:logs:${var.aws_region}:${var.aws_account}:log-group:/aws/lambda/lambdaProvisionerGetTemplates:*"]
    }
  ]
}

module "iam_policy_lambda_provisioner_create_ec2" {
  source  = "mineiros-io/iam-policy/aws"
  version = "~> 0.5.0"

  name = "LambdaProvisionerCreateEc2Policy"

  policy_statements = [
    {
      sid = "LambdaProvisionerCreateEc2CreateLogGroup"

      effect    = "Allow"
      actions   = ["logs:CreateLogGroup"]
      resources = ["arn:aws:logs:${var.aws_region}:${var.aws_account}:*"]
    },
    {
      sid = "LambdaProvisionerCreateEc2PutLogEvents"

      effect    = "Allow"
      actions   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ]
      resources = ["arn:aws:logs:${var.aws_region}:${var.aws_account}:log-group:/aws/lambda/lambdaProvisionerCreateEc2:*"]
    },
    {
      sid = "LambdaProvisionerCreateEc2RunInstances"

      effect    = "Allow"
      actions   = ["ec2:RunInstances"]
      resources = ["*"]
    },
    {
      sid = "LambdaProvisionerCreateEc2CreateTags"

      effect     = "Allow"
      actions    = ["ec2:CreateTags"]
      resources  = ["arn:aws:ec2:region:account:${var.aws_account}/*"]
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

module "iam_role_lambda_provisioner_get_templates" {
  source  = "mineiros-io/iam-role/aws"
  version = "~> 0.6.0"

  name = "LambdaProvisionerGetTemplatesRole"

  assume_role_principals = [
    {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  ]

  policy_arns = [
    module.iam_policy_lambda_provisioner_get_templates.policy.arn
  ]

  tags = {
    Environment = var.provisioner_environment
  }
}

module "iam_role_lambda_provisioner_create_ec2" {
  source  = "mineiros-io/iam-role/aws"
  version = "~> 0.6.0"

  name = "LambdaProvisionerCreateEc2Role"

  assume_role_principals = [
    {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  ]

  policy_arns = [
    module.iam_policy_lambda_provisioner_create_ec2.policy.arn,
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  tags = {
    Environment = var.provisioner_environment
  }
}