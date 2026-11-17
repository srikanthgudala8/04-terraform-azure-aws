# 04 - Terraform on Azure and AWS

Phase 4 of the 60-day journey from AVD support engineer to DevOps engineer (Days 27-38).
Day-by-day plan: **[LEARNING.md](LEARNING.md)**.

Two complete infrastructure-as-code projects:

| Folder | What it builds | Why it matters |
|--------|----------------|----------------|
| `azure/` | Resource group, VNet with subnets and NSGs, **Azure Virtual Desktop** host pool + desktop app group + workspace, remote state in Azure Storage | Turns your AVD experience into an IaC portfolio piece |
| `aws/` | Multi-AZ VPC, ALB, Auto Scaling group running a container, remote state in S3 + DynamoDB | The most common cloud in job postings |

```
azure/
  bootstrap/        one-off: storage account for remote state
  modules/network/  VNet, subnets (for_each), NSGs
  modules/avd/      host pool, registration token, app group, workspace
  envs/dev/         wires the modules together
aws/
  bootstrap/        one-off: S3 bucket + DynamoDB lock table
  modules/vpc/      VPC, public/private subnets, NAT, routes
  modules/compute/  security groups, ALB, launch template, ASG, scaling policy
  envs/dev/         wires the modules together
```

## Azure quick start

```bash
az login
cd azure/bootstrap && terraform init && terraform apply     # note the output values
cd ../envs/dev
terraform init -backend-config="storage_account_name=<from bootstrap output>"
terraform plan
terraform apply
terraform destroy      # when finished
```

The AVD control plane (host pool, application group, workspace) costs almost nothing
by itself. Session host VMs are what cost money, so they are an optional stretch lab (Day 33).

## AWS quick start

```bash
aws configure                                               # or aws sso login
cd aws/bootstrap && terraform init && terraform apply       # note the bucket name
cd ../envs/dev
cp terraform.tfvars.example terraform.tfvars                # set container_image
terraform init -backend-config="bucket=<bucket from bootstrap>"
terraform plan && terraform apply
curl "$(terraform output -raw app_url)/health"
terraform destroy      # NAT gateway and ALB bill hourly
```

The container image comes from `03-github-actions-cicd` (make its GHCR package public).

## What it demonstrates

- Modules with typed, validated inputs and outputs; `for_each` and `count`
- Remote state with locking and versioning (Azure Storage, S3 + DynamoDB)
- Least-privilege networking (NSGs, security groups, private subnets)
- Sensitive outputs (the AVD registration token)
- IMDSv2, encrypted disks, SSM instead of SSH (AWS)
- CI: `terraform fmt -check`, `validate`, tfsec on every PR

## Status

The code parses cleanly but has not been applied to a real account: part of your learning
is to run `terraform fmt`, `validate`, `plan` and `apply` yourself and fix anything your
provider version complains about. That debugging is real DevOps experience.
