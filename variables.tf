variable "parent" {
  description = <<-EOT
    The resource these org policies apply to, in fully-qualified form:
      - "organizations/123456789012"
      - "folders/123456789012"
      - "projects/my-project-id"
    Applying at the organization level requires roles/orgpolicy.policyAdmin on the org.
  EOT
  type        = string

  validation {
    condition     = can(regex("^(organizations|folders|projects)/[a-z0-9][a-z0-9-]*$", var.parent))
    error_message = "parent must be one of organizations/<id>, folders/<id>, or projects/<id>."
  }
}

variable "billing_project" {
  description = "Project ID used for API quota/billing attribution by the provider."
  type        = string
  default     = null
}

variable "allowed_locations" {
  description = <<-EOT
    Allowed value groups/regions for constraints/gcp.resourceLocations
    (constraint #4, data residency). Examples:
      ["in:us-locations"]              # any US region/multi-region
      ["in:eu-locations"]              # any EU region/multi-region
      ["in:us-east1-locations"]        # a single region's value group
      ["us-central1", "us-east1"]      # explicit regions
    See value groups: https://cloud.google.com/resource-manager/docs/organization-policy/defining-locations
  EOT
  type        = list(string)
  default     = ["in:us-locations"]
}
