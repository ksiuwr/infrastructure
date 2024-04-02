# Required for App Engine app to access Secret Manager in runtime
resource "google_secret_manager_secret_iam_member" "service_account_secret_accessor" {
  secret_id = google_secret_manager_secret.django_settings.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = data.google_app_engine_default_service_account.default.member

  # Wait for the service account to be created before assigning roles
  depends_on = [
    google_app_engine_application.zosia_site,
    data.google_app_engine_default_service_account.default
  ]
}

# Required for App Engine app to access Cloud SQL in runtime
resource "google_project_iam_binding" "service_account_cloudsql_client" {
  project = local.project_id
  role    = "roles/cloudsql.client"

  members = [
    data.google_app_engine_default_service_account.default.member,
  ]

  # Wait for the service account to be created before assigning roles
  depends_on = [
    google_app_engine_application.zosia_site,
    data.google_app_engine_default_service_account.default
  ]
}
