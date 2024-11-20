resource "google_service_account" "cloudrun_service_account" {
  account_id   = "zosia-cloudrun-service-account"
  display_name = "Zosia website Cloud Run Service Account"
}

# Required for Cloud Run to access Secret Manager in runtime
resource "google_secret_manager_secret_iam_member" "service_account_secret_accessor" {
  secret_id = google_secret_manager_secret.django_settings.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.cloudrun_service_account.member
}

resource "google_project_iam_binding" "service_account_permissions" {
  for_each = toset([
    "roles/cloudsql.client",         # Required for Cloud Run to access Cloud SQL in runtime
    "roles/storage.objectAdmin",     # Required for Cloud Run to access Cloud Storage with static files in runtime
    "roles/artifactregistry.writer", # Required for uploading zosia Docker image to Artifact Registry during CI/CD
    "roles/run.admin",               # Required for deploying Cloud Run services and jobs
    "roles/iam.serviceAccountUser"   # Required for deploying Cloud Run services and jobs
  ])

  project = local.project_id
  role    = each.value

  members = [
    google_service_account.cloudrun_service_account.member
  ]
}
