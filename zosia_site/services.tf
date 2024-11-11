# Enables required services for the project

resource "google_project_service" "required_services" {
  for_each = toset([
    "secretmanager.googleapis.com",
    "sql-component.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com"
  ])

  project = local.project_id
  service = each.value
}
