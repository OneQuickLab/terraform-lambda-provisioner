output "api_url" {
  value = "${aws_api_gateway_deployment.lambdaProvisioner.invoke_url}"
}

output "sns_topics" {
  value = aws_sns_topic.lambdaProvisioner
}

output "sns_email_subscriptions" {
  value = null_resource.topic_email_subscription
}