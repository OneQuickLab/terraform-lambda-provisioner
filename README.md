# AWS Lambda EC2 Provisioner Demo

## Requirements

### Tooling

* AWS CLI >= 2.1.31
* JQ >= 1.6
* Terraform >= v1.0.9

### AWS Credentials

```shell
$ aws configure --profile=demo
```

Create a `terraform.tf` file with the following content:

```file
provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = "/Users/backtorod/.aws/credentials"
  profile                 = "demo"
}

terraform {
  required_providers {
    archive = "~> 1.3"
  }
}
```

## Initialize

```shell
$ terraform workspace new demo
$ terraform init
```

## Provisioning

### Planning

```shell
$ terraform plan -var-file=demo.tfvars
```

### Applying

```shell
$ TF_VAR_provisioner_deployed_at=$(date +%s) \
    terraform apply -var-file=demo.tfvars
```

If you receive the following message when calling your API endpoint, execute the apply process again:

```json
{
  "message": "Internal server error"
}
```

The stage variable `provisioner_deployed_at` will get updated and this will force an API Deployment.

## Testing

Once resources are provisioned, Terraform will output the AWS API Endpoint URL which can be used to trigger the Lambda functions:

```shell
Apply complete! Resources: 19 added, 0 changed, 0 destroyed.

Outputs:

api_url = "https://80b0x6xz60.execute-api.ca-central-1.amazonaws.com/demo"
```

Two API methods are available. Each one calls a different Lambda function, as follow:

### Function lambdaProvisionerGetTemplates

* `Function Name: lambdaProvisionerGetTemplates`
* `Method: GET`
* `API Path: /templates`

Triggering the `lambdaProvisionerGetTemplates` Lambda function can be achieved as follow:

```bash
$ curl -s https://80b0x6xz60.execute-api.ca-central-1.amazonaws.com/demo/templates | jq .
```

The function will return the available templates that can be used:

```json
{
  "response_code": 200,
  "headers: ": {
    "Content-Type": "application/json"
  },
  "body": {
    "provisioner": {
      "linux": {
        "ami": "ami-0a70476e631caa6d3",
        "instance_type": "t2.micro",
        "public_ip": true,
        "root_storage": 30,
        "key_name": "demo-lambda-provisioner",
        "instance_count": 1,
        "region": "ca-central-1"
      },
      "windows": {
        "ami": "ami-04ce2d3d06e88b4cf",
        "instance_type": "t3.large",
        "public_ip": true,
        "root_storage": 60,
        "key_name": "demo-lambda-provisioner",
        "instance_count": 1,
        "region": "ca-central-1"
      }
    }
  }
}
```

### Function lambdaProvisionerCreateEc2

* `Function Name: lambdaProvisionerCreateEc2`
* `Method: POST`
* `API Path: /provision`

Triggering the `lambdaProvisionerCreateEc2` Lambda function can be achieved as follow:

```bash
$ curl -sX POST https://80b0x6xz60.execute-api.ca-central-1.amazonaws.com/demo/provision\?instanceTemplate\=linux | jq .
```
This function will return the `instanceId` of the newly created EC2 instance:

```json
{
  "instanceId": "i-006604b1175489864"
}
```


### Destroying

```shell
$ terraform destroy -var-file=demo.tfvars
```