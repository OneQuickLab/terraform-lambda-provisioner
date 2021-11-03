# ----------------------------------------------------------------------------------------------------------------------
# PREPARE DEPLOYMENT PACKAGES
# A deployment package is a ZIP archive that contains your function code and dependencies.
# ----------------------------------------------------------------------------------------------------------------------

data "archive_file" "lambda_provisioner_get_templates" {
  type        = "zip"
  source_file = "${path.module}/src/OneQuickLabProvisionerGetTemplates.py"
  output_path = "${path.module}/src/OneQuickLabProvisionerGetTemplates.py.zip"
}

data "archive_file" "lambda_provisioner_create_ec2" {
  type        = "zip"
  source_file = "${path.module}/src/OneQuickLabProvisionerCreateEc2.py"
  output_path = "${path.module}/src/OneQuickLabProvisionerCreateEc2.py.zip"
}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY LAMBDA FUNCTIONS
# ----------------------------------------------------------------------------------------------------------------------

module "lambda_lambda_provisioner_get_templates" {
  source  = "mineiros-io/lambda-function/aws"
  version = "~> 0.5.0"

  function_name = "OneQuickLabProvisionerGetTemplates"
  description   = "AWS Lambda Provisioner - Get Templates"
  filename      = data.archive_file.lambda_provisioner_get_templates.output_path
  runtime       = "python3.8"
  handler       = "OneQuickLabProvisionerGetTemplates.lambda_handler"
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

  function_name = "OneQuickLabProvisionerCreateEc2"
  description   = "AWS Lambda Provisioner - Create EC2 Instance"
  filename      = data.archive_file.lambda_provisioner_create_ec2.output_path
  runtime       = "python3.8"
  handler       = "OneQuickLabProvisionerCreateEc2.lambda_handler"
  timeout       = 30
  memory_size   = 128

  role_arn = module.iam_role_lambda_provisioner_create_ec2.role.arn

  module_tags = {
    Environment = var.provisioner_environment
  }
}