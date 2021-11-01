# AWS Lambda EC2 Provisioner Demo

## Requirements

* Terraform >= v1.0.9

## Initialize

```shell
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

### Destroying

```shell
$ terraform destroy -var-file=demo.tfvars
```