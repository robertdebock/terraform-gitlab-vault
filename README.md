# Terraform GitLab Vault demo

A demo on how GitLab can connect to HashiCorp Vault, authenticate using `JWT` and get AWS credentials.

## Requirements

- A GitLab instance. `gitlab.com` can be used.
- A Vault instance. [AWS Vault](https://registry.terraform.io/modules/robertdebock/vault/aws/latest) can be used. Also see the directory `vault` in this repository.
- A Vault token.

## Setup

Tell the Terraform provider `vault` how to connect to your Vault instance.

```shell
export VAULT_ADDR="https://vault.aws.adfinis.cloud:8200"
export VAULT_TOKEN="XYZ123"
```

Terraform needs to know how to connect to GitLab as well.

```shell
export GITLAB_BASE_URL="https://gitlab.com/"
export GITLAB_TOKEN="XYZ123"
```

Vault will be configured using Terraform using `var.aws_secrets_key` and `var.aws_access_key`. You may already have the environment variables `AWS_ACCESS_KEY` and AWS_SECRET_KEY`. In that case you can pass the value to Terraform:

```shell
export TF_VAR_aws_secret_key=${AWS_SECRET_ACCESS_KEY}
export TF_VAR_aws_access_key=${AWS_ACCESS_KEY_ID}
```

## Deploy

```shell
terraform apply
```
