locals {
  docker_image_url = "${local.region}-docker.pkg.dev/${local.project_id}/${google_artifact_registry_repository.zosia-repo.repository_id}/${local.docker_image_name}:latest"
}

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
        image   = local.docker_image_url
        command = ["./scripts/migrate.sh"]

        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = local.project_id
        }
      }
    }
  }
}

resource "google_cloud_run_v2_job" "collectstatic" {
  name     = "collectstatic"
  location = local.region

  template {
    template {
      service_account = google_service_account.cloudrun_service_account.email

      containers {
        image   = local.docker_image_url
        command = ["./scripts/collectstatic.sh"]

        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = local.project_id
        }

        env {
          name  = "GCS_BUCKET_NAME"
          value = google_storage_bucket.static_files_bucket.name
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
      image   = local.docker_image_url
      command = ["./scripts/start_prod_server.sh"]

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = local.project_id
      }

      env {
        name  = "GCS_BUCKET_NAME"
        value = google_storage_bucket.static_files_bucket.name
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

resource "random_id" "static_files_bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "static_files_bucket" {
  name          = "${random_id.static_files_bucket_prefix.hex}-static-files-bucket"
  location      = local.region
  force_destroy = false
  storage_class = "STANDARD"

  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["*"]
  }
}

# This allows anyone on the internet to view static files
resource "google_storage_bucket_iam_member" "static_files_bucket_public" {
  bucket = google_storage_bucket.static_files_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

