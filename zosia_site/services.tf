# Enables required services for the project

resource "google_project_service" "secretmanager_service" {
  project = local.project_id
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "appengine_service" {
  project = local.project_id
  service = "appenginereporting.googleapis.com"
}

resource "google_project_service" "sql_service" {
  project = local.project_id
  service = "sql-component.googleapis.com"
}
