# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = var.provisioner_api_name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": [
                "*"
            ],
            "Condition" : {
                "StringNotEquals": {
                    "aws:SourceVpce": "${var.aws_api_vpc_endpoint}"
                }
            }
        }
    ]
}
EOF

  endpoint_configuration {
    types = [
      "PRIVATE"
    ]
    vpc_endpoint_ids = [
      var.aws_api_vpc_endpoint
    ]
  }

}

# ----------------------------------------------------------------------------------------------------------------------
# POST - LAMBDA PROVISIONER CREATE EC2
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "createEc2" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "provision"
}

resource "aws_api_gateway_method" "createEc2" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.createEc2.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "createEc2" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.createEc2.id
  http_method = aws_api_gateway_method.createEc2.http_method

  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_lambda_provisioner_create_ec2.function.invoke_arn

  depends_on = [
    module.lambda_lambda_provisioner_create_ec2
  ]
}

resource "aws_api_gateway_method_response" "createEc2" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.createEc2.id
  http_method = aws_api_gateway_integration.createEc2.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "createEc2" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.createEc2.id
  http_method = aws_api_gateway_method_response.createEc2.http_method
  status_code = aws_api_gateway_method_response.createEc2.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_lambda_permission" "createEc2" {
  function_name = "lambdaProvisionerCreateEc2"
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account}:${aws_api_gateway_rest_api.api.id}/*/POST${aws_api_gateway_resource.createEc2.path}"
  depends_on = [
    aws_api_gateway_rest_api.api,
    aws_api_gateway_resource.createEc2
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# GET - LAMBDA PROVISIONER GET TEMPLATES
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "getTemplates" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "templates"
}

resource "aws_api_gateway_method" "getTemplates" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.getTemplates.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "getTemplates" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.getTemplates.id
  http_method = aws_api_gateway_method.getTemplates.http_method

  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = module.lambda_lambda_provisioner_get_templates.function.invoke_arn

}

resource "aws_api_gateway_method_response" "getTemplates" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.getTemplates.id
  http_method = aws_api_gateway_integration.getTemplates.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "getTemplates" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.getTemplates.id
  http_method = aws_api_gateway_method_response.getTemplates.http_method
  status_code = aws_api_gateway_method_response.getTemplates.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_lambda_permission" "getTemplates" {
  function_name = "lambdaProvisionerGetTemplates"
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account}:${aws_api_gateway_rest_api.api.id}/*/GET${aws_api_gateway_resource.getTemplates.path}"
  depends_on = [
    aws_api_gateway_rest_api.api,
    aws_api_gateway_resource.getTemplates
  ]
}

resource "aws_api_gateway_deployment" "lambdaProvisioner" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.provisioner_api_stage

  depends_on = [
    aws_api_gateway_method.getTemplates,
    aws_api_gateway_method.createEc2,
    aws_api_gateway_integration.getTemplates,
    aws_api_gateway_integration.createEc2
  ]

  variables = {
    provisioner_deployed_at = "${var.provisioner_deployed_at}"
  }

}
