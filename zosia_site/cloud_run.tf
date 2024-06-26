resource "google_artifact_registry_repository" "zosia-repo" {
  location      = local.region
  repository_id = "zosia-repo"
  description   = "Repository for zosia site production images"
  format        = "DOCKER"

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 5
    }
  }
}

resource "google_cloud_run_v2_job" "migrate" {
  name     = "migrate"
  location = local.region

  template {
    template {
      service_account = google_service_account.cloudrun_service_account.email

      containers {
        image   = "${local.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.zosia-repo.repository_id}/${local.docker_image_name}:latest"
        command = ["./scripts/migrate.sh"]

        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = local.project_id
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service" "zosia_site" {
  name     = "zosia"
  location = local.region

  template {
    service_account = google_service_account.cloudrun_service_account.email

    containers {
      image   = "${local.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.zosia-repo.repository_id}/${local.docker_image_name}:latest"
      command = ["./scripts/start_prod_server.sh"]

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = local.project_id
      }

      # TODO: Add domain mapping to zosia.org and www.zosia.org
      env {
        name  = "HOSTS"
        value = "zosia.org, www.zosia.org"
      }
    }
  }
}

# This allows zosia website to be accessed by anyone without authentication
resource "google_cloud_run_v2_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.zosia_site.location
  name     = google_cloud_run_v2_service.zosia_site.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

