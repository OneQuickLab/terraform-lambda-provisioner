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

variable "aws_api_vpc_endpoint" {
  description = "AWS API Gateway VPC Endpoint (for PRIVATE endpoints)."
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

variable "provisioner_deployed_at" {
  description = "Timestamp when provisioner API was deployed."
  type        = number
}
