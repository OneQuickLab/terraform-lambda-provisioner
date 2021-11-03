output "api_url" {
  value = aws_api_gateway_deployment.OneQuickLabProvisioner.invoke_url
}