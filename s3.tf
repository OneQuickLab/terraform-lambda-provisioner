# ----------------------------------------------------------------------------------------------------------------------
# CREATE S3 BUCKET AND UPLOAD TEMPLATES
# ----------------------------------------------------------------------------------------------------------------------

module "lambda_provisioner_templates" {
  source  = "mineiros-io/s3-bucket/aws"
  version = "~> 0.6.0"

  bucket = var.templates_bucket_name

  versioning = true

  tags = {
    Name = var.templates_bucket_name
  }
}

resource "aws_s3_bucket_object" "templates" {

  source = "${path.module}/src/templates.json"
  bucket = module.lambda_provisioner_templates.id
  key    = "templates.json"
  acl    = "private"

}