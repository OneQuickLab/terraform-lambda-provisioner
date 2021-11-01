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

### Destroying

```shell
$ terraform destroy -var-file=demo.tfvars
```