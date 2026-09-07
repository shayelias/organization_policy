output "applied_policies" {
  description = "The org policy constraints managed by this module and their target parent."
  value = {
    parent = var.parent
    constraints = [
      google_org_policy_policy.disable_sa_key_creation.name,
      google_org_policy_policy.deny_vm_external_ip.name,
      google_org_policy_policy.enforce_uniform_bucket_access.name,
      google_org_policy_policy.restrict_resource_locations.name,
      google_org_policy_policy.disable_default_sa_role_grant.name,
    ]
  }
}
