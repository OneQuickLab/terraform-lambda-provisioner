# ----------------------------------------------------------------------------------------------------------------------
# CREATE IAM POLICIES
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# provisionerGetTemplates - Policy and Role
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "LambdaProvisionerGetTemplatesPolicy" {
  name = "LambdaProvisionerGetTemplatesPolicy"
  role = module.iam_role_lambda_provisioner_get_templates.role.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "LambdaProvisionerGetTemplatesS3ReadOnly",
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
            "Sid": "LambdaProvisionerGetTemplatesCreateLogGroup",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account}:*"
        },
        {
            "Sid": "LambdaProvisionerGetTemplatesSNSPublish",
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "${aws_sns_topic.lambdaProvisioner.arn}"
        },
        {
            "Sid": "LambdaProvisionerGetTemplatesPutLogEvents",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream"
            ],
            "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account}:log-group:/aws/lambda/lambdaProvisionerGetTemplates:*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "LambdaProvisionerCreateEc2Policy" {
  name = "LambdaProvisionerCreateEc2Policy"
  role = module.iam_role_lambda_provisioner_create_ec2.role.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "LambdaProvisionerGetTemplatesS3ReadOnly",
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
            "Sid": "LambdaProvisionerGetTemplatesSNSPublish",
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "${aws_sns_topic.lambdaProvisioner.arn}"
        },
        {
            "Sid": "LambdaProvisionerCreateEc2RunInstances",
            "Effect": "Allow",
            "Action": "ec2:RunInstances",
            "Resource": "*"
        },
        {
            "Sid": "LambdaProvisionerCreateEc2CreateTags",
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

  name = "LambdaProvisionerGetTemplatesRole"

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

  name = "LambdaProvisionerCreateEc2Role"

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