resource "google_service_account" "cloudrun_service_account" {
  account_id   = "cloudrun-service-account"
  display_name = "Cloud Run Service Account"
}

# Required for Cloud Run to access Secret Manager in runtime
resource "google_secret_manager_secret_iam_member" "service_account_secret_accessor" {
  secret_id = google_secret_manager_secret.django_settings.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.cloudrun_service_account.member
}

# Required for Cloud Run to access Cloud SQL in runtime
resource "google_project_iam_binding" "service_account_cloudsql_client" {
  project = local.project_id
  role    = "roles/cloudsql.client"

  members = [
    google_service_account.cloudrun_service_account.member
  ]
}

# Required for Cloud Run to access Cloud Storage with static files in runtime
resource "google_project_iam_binding" "cloud_storage_admin" {
  project = local.project_id
  role    = "roles/storage.objectAdmin"

  members = [
    google_service_account.cloudrun_service_account.member
  ]

}
