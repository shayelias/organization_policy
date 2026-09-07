# GCP Recommended Organization Policies (Terraform)

Terraform for a security baseline of **five recommended GCP Organization Policies**,
managed with the modern [`google_org_policy_policy`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/org_policy_policy)
resource. Apply at the **organization**, **folder**, or **project** level via a
single `parent` variable.

## The five policies

| # | Constraint | Type | Effect |
|---|------------|------|--------|
| 1 | `iam.disableServiceAccountKeyCreation` | Boolean (enforce) | Kills long-lived user-managed SA JSON keys — the #1 cause of leaked GCP creds in public repos. Forces Workload Identity Federation / attached SAs. |
| 2 | `compute.vmExternalIpAccess` | List (deny all) | No VM may receive a public IP. Ingress terminates at a Load Balancer / Cloud Armor; egress via Cloud NAT. |
| 3 | `storage.uniformBucketLevelAccess` | Boolean (enforce) | Disables legacy object ACLs; bucket access is IAM-only. Prevents an `allUsers:READER` object inside an otherwise private bucket. |
| 4 | `gcp.resourceLocations` | List (allow) | Data residency — resources may only be created in approved regions (default `in:us-locations`). |
| 5 | `resourcemanager.disableDefaultServiceAccountRoleGrant` | Boolean (enforce) | New projects no longer auto-grant `roles/editor` to the legacy Compute Engine default SA. |

## Usage

```bash
# 1. Configure
cp terraform.tfvars.example terraform.tfvars
#    edit: parent (org/folder/project), allowed_locations, billing_project

# 2. Authenticate (no keys committed — uses ADC)
gcloud auth application-default login
#    or set GOOGLE_APPLICATION_CREDENTIALS via Workload Identity Federation

# 3. Plan & apply
terraform init
terraform plan
terraform apply
```

### Choosing the `parent`

```hcl
parent = "organizations/123456789012"  # org-wide  (needs roles/orgpolicy.policyAdmin on the org)
parent = "folders/123456789012"        # a folder  (needs policyAdmin on the folder)
parent = "projects/ai-sec-499516"      # one project
```

### Data residency (`allowed_locations`)

```hcl
allowed_locations = ["in:us-locations"]        # any US region/multi-region
allowed_locations = ["in:eu-locations"]        # any EU region/multi-region
allowed_locations = ["us-central1", "us-east1"] # explicit regions
```
Value groups: https://cloud.google.com/resource-manager/docs/organization-policy/defining-locations

## Requirements

- Terraform >= 1.5, `hashicorp/google` provider >= 5.0
- The Org Policy API (`orgpolicy.googleapis.com`) enabled
- IAM: `roles/orgpolicy.policyAdmin` on the target `parent`

## Notes & caveats

- These constraints are **preventive**. They stop *new* violations; they do not
  retroactively remediate existing public IPs, non-uniform buckets, or SA keys.
- Rolling out at the org level affects **all** projects — validate on a folder or
  a single project first.
- No credentials or state are committed (see `.gitignore`). Use remote state
  (e.g. a GCS backend) for team use.
