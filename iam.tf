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
      actions   = [
        "ec2:RunInstances",
        "ec2:CreateTags"
      ]
      resources = [
        "*",
        "arn:aws:ec2:region:account:*/*"
      ]
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