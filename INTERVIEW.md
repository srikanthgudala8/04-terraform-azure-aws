# Interview notes: Terraform AWS infrastructure

## 60-second pitch

"I built a modular Terraform setup for a highly available web tier on AWS: a VPC across
two AZs with public and private subnets, an ALB in front, and an auto-scaling group of
instances in private subnets running a container. State lives in S3 with DynamoDB
locking, created by a bootstrap stack. CI runs fmt, validate and tfsec on every PR."

## Design decisions

- **Modules vs one big file:** vpc and compute are reusable across environments; the
  environment folder only wires inputs. Adding `envs/prod` means a new folder, not a copy of resources.
- **Remote state + locking:** S3 versioning gives state history and recovery; DynamoDB
  prevents two applies corrupting state.
- **Why bootstrap separately?** Chicken-and-egg: the backend can't store its own state
  until it exists. Bootstrap uses local state once.
- **Private subnets + SG referencing:** the app SG allows ingress only from the ALB SG,
  not from CIDR ranges, so access follows the load balancer rather than IPs.
- **SSM instead of SSH:** no open port 22, no key management, sessions are audited.
- **NAT trade-off:** one NAT is cheap but a single-AZ failure point; one per AZ is HA.
  Exposed as a variable.
- **`create_before_destroy` + `name_prefix`:** lets Terraform replace security groups and
  launch templates without name collisions or downtime.

## Likely questions

1. **What happens if two people run apply at once?** The DynamoDB lock makes the second
   fail until the first finishes.
2. **How do you manage multiple environments?** Separate root modules (or workspaces)
   with their own state keys, sharing modules. Directories are clearer and safer than
   workspaces for differing configs.
3. **Explain `count` vs `for_each`.** `count` is index-based, so removing a middle item
   shifts the rest and can recreate resources. `for_each` keys by stable name. Subnets here
   use `count` because they are ordered by AZ; for named resources I'd use `for_each`.
4. **How do you handle secrets in Terraform?** Never in code or tfvars in git. Use Secrets
   Manager / SSM Parameter Store, mark variables `sensitive`, and remember state can contain
   secrets, so the bucket is encrypted and access-controlled.
5. **What is drift and how do you detect it?** Real infra changed outside Terraform.
   `terraform plan` shows it; schedule a nightly plan in CI to alert on drift.
6. **How do you import existing resources?** `terraform import` or `import` blocks, then
   write matching config until plan is clean.
7. **`terraform taint` / `-replace`?** Force recreation of a resource: `terraform apply -replace=ADDR`.
8. **How would you promote this to prod?** Add `envs/prod` with `single_nat_gateway = false`,
   larger instances, HTTPS listener with ACM certificate, WAF, and a required-approval apply pipeline.

## What I'd add next (good to mention)

HTTPS with ACM and a Route 53 record, an RDS module, CloudWatch alarms, a pull-request
`plan` comment via OIDC, and Terragrunt or Terraform Cloud for larger setups.

## Be upfront about

Run `terraform apply` in your own AWS account at least once before the interview so you
can speak from experience. It costs money (NAT + ALB), so destroy after practising.

---

## Azure and AVD additions

- **Pitch:** "I support Azure Virtual Desktop in production, and I also codify it: a Terraform
  module that creates the host pool, desktop application group and workspace, on top of a
  VNet module with per-subnet NSGs and remote state in Azure Storage."
- **Why Azure Storage for state?** Blob lease gives state locking, versioning gives recovery,
  and access is controlled with Azure RBAC.
- **How do session hosts join the pool?** With the registration token (sensitive, short-lived),
  usually via a VM extension. Rotate the token and never commit it.
- **How would you scale AVD cost-effectively?** Scaling plans, start VM on connect, depth-first
  load balancing at quiet times, deallocate idle hosts.
- **Azure vs AWS terms:** Resource group (no direct AWS equivalent, closest is tags + CloudFormation stack),
  VNet = VPC, NSG = security group + NACL blend, Azure Storage backend = S3 + DynamoDB.
- **Authentication in CI:** OIDC federated credential on an Entra app registration, no client secret.
