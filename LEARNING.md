# Phase 4 - Infrastructure as Code with Terraform (Days 27-38)

**Goal:** provision, change and destroy cloud infrastructure safely and repeatably on
Azure (first) and AWS, using modules, remote state and CI.

**Setup:** install Terraform, the Azure CLI (`az`) and AWS CLI. Use a free Azure account
and AWS free tier. **Set a budget alert in both clouds on Day 27.** Always `terraform destroy`
at the end of a session.

---

## Day-by-day plan

### Day 27 - IaC concepts, first resource
- **Learn:** why IaC (repeatable, reviewable, versioned), declarative vs imperative, providers, resources, the workflow `init -> plan -> apply -> destroy`.
- **Lab:** create a resource group and a storage account in a scratch folder. Run `plan`, read it carefully, `apply`, change a tag, `plan` again, then `destroy`.
- **Done when:** you can explain every symbol in a plan (`+ - ~ -/+`).

### Day 28 - Variables, outputs, locals, data sources
- **Learn:** `variable` types and validation, `tfvars`, `locals`, `output` (and `sensitive`), `data` sources, expressions and functions (`merge`, `lookup`, `cidrsubnet`, `format`).
- **Lab:** refactor Day 27 so name, location and tags are variables, and print the storage account endpoint as an output.
- **Done when:** nothing environment-specific is hard-coded.

### Day 29 - State and remote backends
- **Learn:** what state is, why it must be protected, locking, remote state in Azure Storage, `terraform state list/show/mv/rm`.
- **Lab:** apply `azure/bootstrap`, then init `azure/envs/dev` against the new backend. Open the blob in the portal and look at the state. **Never edit state by hand; never commit it.**
- **Done when:** you can explain what happens if two people apply at the same time.

### Day 30 - Azure networking
- **Learn:** VNet, subnets, NSGs, route tables, peering. Compare with AWS VPC concepts.
- **Lab:** read `azure/modules/network`. Add an NSG rule allowing only HTTPS to the `app` subnet using `azurerm_network_security_rule`. Run `plan` and check the diff.
- **Done when:** you can draw the VNet from the code.

### Day 31 - Modules
- **Learn:** module inputs/outputs, composition, versioning, registry modules vs your own, when not to make a module.
- **Lab:** add a third subnet `data` to `azure/envs/dev` without touching the module, then add a `nsg_rules` variable to the module.
- **Done when:** adding a subnet is a one-line change.

### Day 32 - Loops, conditionals, compute
- **Learn:** `count` vs `for_each` (and why `for_each` is usually safer), `dynamic` blocks, conditional expressions, `depends_on`, lifecycle (`create_before_destroy`, `prevent_destroy`, `ignore_changes`).
- **Lab:** create 2 Linux VMs (Standard_B1s) with `for_each`, no public IP, SSH key auth. Remove one from the map and see which one is destroyed.
- **Done when:** you understand the "index shift" problem with `count`.

### Day 33 - A web tier on Azure VMs
- **Learn:** how Azure Standard Load Balancer works (frontend IP, backend pool, health probe, rule), why VMs get no public IP, cloud-init for first-boot setup, system-assigned managed identity.
- **Lab:** read `azure/modules/webserver`, apply it, then `curl` the `web_url` output. SSH is closed, so find the VMs' private IPs in the outputs and explain why you cannot reach them directly. Stop one VM and watch the health probe route traffic to the other.
- **Stretch (costs money, destroy after):** add an NSG rule for SSH from your own IP only, or add an Azure Bastion host.
- **Interview value:** "I built a load-balanced Linux web tier in Terraform with modules, for_each and secure defaults" is a clear, checkable claim.

### Day 34 - Terraform in CI
- **Learn:** pipelines for IaC: `fmt`, `validate`, `plan` on PR, approval, `apply` on merge. tfsec / Checkov for security scanning, OIDC login to Azure.
- **Lab:** read `.github/workflows/terraform.yml`. Add a job that runs `terraform plan` for `azure/envs/dev` using OIDC (see Phase 3 Day 23). Break formatting on purpose and watch it fail.
- **Done when:** a PR shows you a plan before anything changes.

### Day 35 - AWS: provider and VPC
- **Learn:** AWS provider, credentials (SSO profiles), VPC, subnets, route tables, internet and NAT gateways.
- **Lab:** read `aws/modules/vpc`. Draw it. Apply `aws/bootstrap`, then plan `aws/envs/dev` and read the plan resource by resource.
- **Done when:** you can map each Azure networking concept to its AWS equivalent.

### Day 36 - AWS: load balancer and autoscaling
- **Learn:** ALB, target groups, security group chaining, launch templates, ASG, target tracking scaling, IAM roles for EC2.
- **Lab:** read `aws/modules/compute`, apply `aws/envs/dev`, hit the ALB URL, then terminate an instance in the console and watch the ASG replace it.
- **Done when:** you can explain why instances are in private subnets.

### Day 37 - Environments, workspaces, import, drift
- **Learn:** one folder per environment vs workspaces, `terraform import` / `import` blocks, drift detection (`plan -refresh-only`), `taint` / `-replace`.
- **Lab:** change a tag in the console, run `plan`, see the drift, then fix it two ways (revert in code or accept in state). Import an existing resource group into a new config.
- **Done when:** a manual console change no longer scares you.

### Day 38 - Capstone and clean-up
- **Capstone:** `azure/envs/prod` that reuses the same modules with different inputs (bigger limits, different CIDRs), plus a README with an architecture diagram and a cost estimate (`infracost` is free for small use).
- **Clean up:** destroy everything. Check the portal and AWS console for leftovers.

---

## Terraform habits that impress interviewers
- Pin provider and Terraform versions. Commit `.terraform.lock.hcl`.
- Never commit `*.tfstate` or secrets. Use Key Vault / Secrets Manager.
- Always read the plan. Treat `-/+` (replace) as a stop-and-think moment.
- Small modules with clear inputs. Prefer `for_each` over `count` for named things.
- Tag everything (`Project`, `Environment`, `ManagedBy`, `Owner`) and use a naming convention.

## Troubleshooting
- "Error acquiring the state lock": another run is active, or a crash left a lock. `terraform force-unlock <ID>` only after confirming nobody is running.
- Provider auth errors: `az account show` / `aws sts get-caller-identity`.
- "Resource already exists": import it, or it was created outside Terraform.
- Surprising replace: read which attribute is "forces replacement".
- Storage account name already taken: names are globally unique, the bootstrap adds a random suffix for this reason.

## Check yourself
1. What is in the state file and why is it sensitive?
2. `count` vs `for_each`: when does each cause trouble?
3. How do you share infrastructure between teams without copy-paste?
4. What is drift and how do you detect and fix it?
5. How do you manage secrets with Terraform?
6. Explain the Terraform workflow in a CI/CD pipeline.
7. How would you move a resource between modules without destroying it? (`moved` block)
