# Terraria Terraform
Sets up an environment in AWS to host a public terraria server.

# Prerequisites
1. Terraform
1. AWS Access Key
1. AWS Secret Key
1. AWS S3 bucket (If you want to backup your world)
1. SSH Keypair

# Setup
Create secrets.auto.tfvars file with the following contents
```terraform
aws_access_key = "<aws_access_key>"
aws_secret_key = "<aws_secret_key>"

terraria_world_s3_bucket = "<terraria_world_s3_bucket>"

authorized_key = "<ssh_public_key>"

terraria_config_password = "<terraria_config_password>"
```
You can change other default settings like the terraria server port, in this file or other `*.auto.tf` files. See `variables.tf` for options.

# Usage
## Initialize
```bash
terraform init
```

## Create infrastructure
```bash
terraform apply
```
And confirm apply

## Check server status
```bash
ssh admin@<terarria_server_ip> sudo systemctl status terraria.service
```
*note: it may take a few minutes for the terraria server to start*

## Backup world
```bash
ssh admin@<terarria_server_ip> sudo systemctl start terraria-world-backup.service
```
*note: it may take a few minutes for the terraria server to start*

## Destroy Infrastructure
```bash
terraform destroy
```
And confirm destroy
