# ----------------------------------------------------------------------------------------------------------------------
# CREATE IAM POLICIES
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# provisionerGetTemplates - Policy and Role
# ----------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "iam_policy_document_lambda_provisioner_get_templates" {

  statement {
    sid = "LambdaProvisionerGetTemplatesS3ReadOnly"

    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3-object-lambda:Get*",
      "s3-object-lambda:List*"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]

  }

  statement {
    sid = "LambdaProvisionerGetTemplatesCreateLogGroup"

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup"
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:${var.aws_account}:*"
    ]

  }

  statement {
    sid = "LambdaProvisionerGetTemplatesPutLogEvents"

    effect = "Allow"

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:${var.aws_account}:log-group:/aws/lambda/lambdaProvisionerGetTemplates:*"
    ]

  }

}

resource "aws_iam_policy" "iam_policy_lambda_provisioner_get_templates" {

  name   = "LambdaProvisionerGetTemplatesPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.iam_policy_document_lambda_provisioner_get_templates.json

}

# ----------------------------------------------------------------------------------------------------------------------
# provisionerCreateEc2 - Policy and Role
# ----------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "iam_policy_document_lambda_provisioner_crete_ec2" {

  statement {
    sid = "LambdaProvisionerGetTemplatesS3ReadOnly"

    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3-object-lambda:Get*",
      "s3-object-lambda:List*"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]

  }

  statement {
    sid = "LambdaProvisionerCreateEc2RunInstances"

    effect = "Allow"

    actions = [
      "ec2:RunInstances"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "LambdaProvisionerCreateEc2CreateTags"

    effect = "Allow"

    actions = [
      "ec2:CreateTags"
    ]

    resources = [
      "arn:aws:ec2:${var.aws_region}:${var.aws_account}:*/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = [
        "RunInstances"
      ]
    }

  }

}

resource "aws_iam_policy" "iam_policy_lambda_provisioner_create_ec2" {

  name   = "LambdaProvisionerCreateEc2Policy"
  path   = "/"
  policy = data.aws_iam_policy_document.iam_policy_document_lambda_provisioner_crete_ec2.json

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
    aws_iam_policy.iam_policy_lambda_provisioner_get_templates.arn
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
    aws_iam_policy.iam_policy_lambda_provisioner_create_ec2.arn
  ]

  tags = {
    Environment = var.provisioner_environment
  }
}