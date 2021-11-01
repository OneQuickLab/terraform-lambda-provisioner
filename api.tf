resource "aws_api_gateway_rest_api" "lambdaProvisioner" {
  name        = "lambdaProvisioner"
}


resource "aws_api_gateway_resource" "lambdaProvisionerCreateEc2" {
  path_part   = "provision"
  parent_id   = aws_api_gateway_rest_api.lambdaProvisioner.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.lambdaProvisioner.id
}

resource "aws_api_gateway_method" "lambdaProvisionerCreateEc2" {
  rest_api_id   = aws_api_gateway_rest_api.lambdaProvisioner.id
  resource_id   = aws_api_gateway_resource.lambdaProvisionerCreateEc2.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambdaProvisionerCreateEc2" {
  rest_api_id = aws_api_gateway_rest_api.lambdaProvisioner.id
  resource_id = aws_api_gateway_resource.lambdaProvisionerCreateEc2.id
  http_method = aws_api_gateway_method.lambdaProvisionerCreateEc2.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_lambda_provisioner_create_ec2.function.invoke_arn
}

resource "aws_api_gateway_method_response" "lambdaProvisionerCreateEc2" {
  rest_api_id = aws_api_gateway_rest_api.lambdaProvisioner.id
  resource_id = aws_api_gateway_resource.lambdaProvisionerCreateEc2.id
  http_method = aws_api_gateway_method.lambdaProvisionerCreateEc2.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_resource" "lambdaProvisionerGetTemplates" {
  path_part   = "templates"
  parent_id   = aws_api_gateway_rest_api.lambdaProvisioner.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.lambdaProvisioner.id
}

resource "aws_api_gateway_method" "lambdaProvisionerGetTemplates" {
  rest_api_id   = aws_api_gateway_rest_api.lambdaProvisioner.id
  resource_id   = aws_api_gateway_resource.lambdaProvisionerGetTemplates.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambdaProvisionerGetTemplates" {
  rest_api_id = aws_api_gateway_rest_api.lambdaProvisioner.id
  resource_id = aws_api_gateway_resource.lambdaProvisionerGetTemplates.id
  http_method = aws_api_gateway_method.lambdaProvisionerGetTemplates.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_lambda_provisioner_get_templates.function.invoke_arn
}

resource "aws_api_gateway_method_response" "lambdaProvisionerGetTemplates" {
  rest_api_id = aws_api_gateway_rest_api.lambdaProvisioner.id
  resource_id = aws_api_gateway_resource.lambdaProvisionerGetTemplates.id
  http_method = aws_api_gateway_method.lambdaProvisionerGetTemplates.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_deployment" "lambdaProvisionerDeploy" {
  depends_on = [
    aws_api_gateway_integration.lambdaProvisionerCreateEc2,
    aws_api_gateway_integration.lambdaProvisionerGetTemplates,
  ]

  rest_api_id = aws_api_gateway_rest_api.lambdaProvisioner.id
  stage_name  = var.provisioner_api_stage
}

output "base_url" {
  value = aws_api_gateway_deployment.lambdaProvisionerDeploy.invoke_url
}