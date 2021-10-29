# ----------------------------------------------------------------------------------------------------------------------
# CREATE A TEMPORARY SSH KEY PAIR
# ----------------------------------------------------------------------------------------------------------------------

module "lambda_provisioner_keypair" {
  source  = "cloudposse/key-pair/aws"
  version = "0.18.2"

  name                  = var.provisioner_keypair
  ssh_public_key_path   = "${path.module}/src/secrets"
  generate_ssh_key      = "true"
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
}