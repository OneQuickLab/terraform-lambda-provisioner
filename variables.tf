# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created."
  type        = string
}

variable "aws_account" {
  description = "AWS account where resources will be created."
  type        = string
}

variable "provisioner_environment" {
  description = "Environment of the provisioner."
  type        = string
}

variable "templates_bucket_name" {
  description = "S3 bucket name that will host the templates.json file."
  type        = string
}

variable "provisioner_keypair" {
  description = "SSH key pair used by EC2 instances."
  type        = string
}

variable "provisioner_api_name" {
  description = "AWS API Gateway Name."
  type        = string
}

variable "provisioner_api_stage" {
  description = "AWS API Gateway Stage."
  type        = string
}

variable "provisioner_sns_topic" {
  description = "The SNS topics name to create."
  type        = string
}

variable "provisioner_sns_subscriptions" {
  description = "Subscriptions associated with topics previously created."
  type        = list(object({
    endpoints  = string,
    topic      = string,
    type       = string
  }))
  default = []
}

variable "provisioner_sns_subscription_enabled" {
  description = "Conditionally enables this module (and all it's ressources)."
  type        = bool
  default     = true
}