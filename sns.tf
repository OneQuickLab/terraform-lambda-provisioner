resource "aws_sns_topic" "lambdaProvisioner" {
    name = var.provisioner_sns_topic
    display_name = var.provisioner_sns_topic
    delivery_policy = <<FILE
{
    "http": {
        "defaultHealthyRetryPolicy": {
            "minDelayTarget": 20,
            "maxDelayTarget": 20,
            "numRetries": 3,
            "numMaxDelayRetries": 0,
            "numNoDelayRetries": 0,
            "numMinDelayRetries": 0,
            "backoffFunction": "linear"
        },
        "disableSubscriptionOverrides": false,
        "defaultThrottlePolicy": {
            "maxReceivesPerSecond": 1
        }
    }
}
FILE

}

locals {
  email_subs = flatten([
    for sub in var.provisioner_sns_subscriptions: [
      for endpoint in split(",", sub.endpoints): {
        endpoint = endpoint
        topic    = sub.topic
      }
    ] if sub.type == "email"
  ])
}

resource "null_resource" "topic_email_subscription" {
    for_each = {
      for sub in local.email_subs : "${sub.endpoint}-${sub.topic}" => sub
    }

    provisioner "local-exec" {
        command = <<COMMAND
aws configure set region ${var.aws_region}
aws sns subscribe --topic-arn ${aws_sns_topic.lambdaProvisioner[each.value.topic].arn} --protocol email --notification-endpoint ${each.value.endpoint}
COMMAND
    }
}