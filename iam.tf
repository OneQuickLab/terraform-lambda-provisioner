# ----------------------------------------------------------------------------------------------------------------------
# CREATE IAM POLICIES
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# provisionerGetTemplates - Policy and Role
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "OneQuickLabProvisionerGetTemplatesPolicy" {
  name = "OneQuickLabProvisionerGetTemplatesPolicy"
  role = module.iam_role_lambda_provisioner_get_templates.role.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "OneQuickLabProvisionerGetTemplatesS3ReadOnly",
            "Effect": "Allow",
            "Action": [
                "s3:List*",
                "s3:Get*",
                "s3-object-lambda:List*",
                "s3-object-lambda:Get*"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Sid": "OneQuickLabProvisionerGetTemplatesCreateLogGroup",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account}:*"
        },
        {
            "Sid": "OneQuickLabProvisionerGetTemplatesPutLogEvents",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream"
            ],
            "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account}:log-group:/aws/lambda/OneQuickLabProvisionerGetTemplates:*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "OneQuickLabProvisionerCreateEc2Policy" {
  name = "OneQuickLabProvisionerCreateEc2Policy"
  role = module.iam_role_lambda_provisioner_create_ec2.role.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "OneQuickLabProvisionerGetTemplatesS3ReadOnly",
            "Effect": "Allow",
            "Action": [
                "s3:List*",
                "s3:Get*",
                "s3-object-lambda:List*",
                "s3-object-lambda:Get*"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Sid": "OneQuickLabProvisionerCreateEc2RunInstances",
            "Effect": "Allow",
            "Action": [
              "ec2:DescribeInstanceStatus",
              "ec2:RunInstances"
            ],
            "Resource": "*"
        },
        {
            "Sid": "OneQuickLabProvisionerCreateEc2CreateTags",
            "Effect": "Allow",
            "Action": "ec2:CreateTags",
            "Resource": "arn:aws:ec2:${var.aws_region}:${var.aws_account}:*/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": [
                        "RunInstances"
                    ]
                }
            }
        },
        {
            "Sid": "OneQuickLabProvisionerGetTemplatesCreateLogGroup",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account}:*"
        },
        {
            "Sid": "OneQuickLabProvisionerGetTemplatesPutLogEvents",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream"
            ],
            "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account}:log-group:/aws/lambda/OneQuickLabProvisionerCreateEc2:*"
        }
    ]
}
EOF
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE IAM ROLES
# ----------------------------------------------------------------------------------------------------------------------

module "iam_role_lambda_provisioner_get_templates" {
  source  = "mineiros-io/iam-role/aws"
  version = "~> 0.6.0"

  name = "OneQuickLabProvisionerGetTemplatesRole"

  assume_role_principals = [
    {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  ]

  tags = {
    Environment = var.provisioner_environment
  }
}

module "iam_role_lambda_provisioner_create_ec2" {
  source  = "mineiros-io/iam-role/aws"
  version = "~> 0.6.0"

  name = "OneQuickLabProvisionerCreateEc2Role"

  assume_role_principals = [
    {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  ]

  tags = {
    Environment = var.provisioner_environment
  }
}