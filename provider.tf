provider "google" {
  # Credentials come from Application Default Credentials (ADC) or the
  # GOOGLE_APPLICATION_CREDENTIALS env var. No keys are committed to the repo.
  # `project` is only used for quota/billing attribution of API calls; the
  # org policies themselves are applied to `var.parent` (org / folder / project).
  project = var.billing_project
}
