# -----------------------------------------------------------------------------
# Five recommended GCP Organization Policies (security baseline)
# Managed with the modern google_org_policy_policy resource.
#
# The policy resource `name` must be "<parent>/policies/<constraint>", where
# <parent> is organizations/<id>, folders/<id>, or projects/<id>.
# -----------------------------------------------------------------------------

# 1. Kill long-lived service account keys.
#    Boolean: enforce = TRUE  -> user-managed SA key creation is denied.
#    Forces Workload Identity Federation / attached service accounts instead.
resource "google_org_policy_policy" "disable_sa_key_creation" {
  name   = "${var.parent}/policies/iam.disableServiceAccountKeyCreation"
  parent = var.parent

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

# 2. Block public (external) IPs on Compute Engine VMs.
#    List: deny_all = TRUE  -> no VM may receive an external IP.
#    Ingress should terminate at a Load Balancer / Cloud Armor; egress via Cloud NAT.
resource "google_org_policy_policy" "deny_vm_external_ip" {
  name   = "${var.parent}/policies/compute.vmExternalIpAccess"
  parent = var.parent

  spec {
    rules {
      deny_all = "TRUE"
    }
  }
}

# 3. Enforce Uniform Bucket-Level Access on all Cloud Storage buckets.
#    Boolean: enforce = TRUE  -> disables legacy object ACLs; IAM only.
resource "google_org_policy_policy" "enforce_uniform_bucket_access" {
  name   = "${var.parent}/policies/storage.uniformBucketLevelAccess"
  parent = var.parent

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

# 4. Restrict resource locations (data residency).
#    List: allow only the approved location value groups / regions.
resource "google_org_policy_policy" "restrict_resource_locations" {
  name   = "${var.parent}/policies/gcp.resourceLocations"
  parent = var.parent

  spec {
    rules {
      values {
        allowed_values = var.allowed_locations
      }
    }
  }
}

# 5. Disable automatic role grants to the default service account.
#    Boolean: enforce = TRUE  -> new projects do NOT grant roles/editor to the
#    legacy Compute Engine default service account.
resource "google_org_policy_policy" "disable_default_sa_role_grant" {
  name   = "${var.parent}/policies/resourcemanager.disableDefaultServiceAccountRoleGrant"
  parent = var.parent

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}
