aws_region              = "ca-central-1"
aws_account             = "176399646443"
provisioner_environment = "demo"
templates_bucket_name   = "demo-lambda-provisioner"
provisioner_keypair     = "demo-lambda-provisioner"
provisioner_api_name    = "lambdaProvisioner"
provisioner_api_stage   = "demo"

provisioner_sns_topic = "lambdaProvisioner"

provisioner_sns_subscriptions = [
  {
    endpoints  = "me@backtorod.com",
    topic      = "lambdaProvisioner",
    type       = "email"
  }
]