# ----------------------------------------------------------------------------------------------------------------------
# SETUP PROVIDER
# ----------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region  = var.aws_region
  profile = "demo"

  shared_credentials_file = "/Users/backtorod/.aws/credentials"
}

terraform {
  required_providers {
    archive = "~> 1.3"
  }
}