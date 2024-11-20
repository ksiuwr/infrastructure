locals {
  docker_dummy_image_url = "us-docker.pkg.dev/cloudrun/container/hello"
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

resource "google_cloud_run_v2_job" "createsuperuser" {
  name     = "createsuperuser"
  location = local.region

  template {
    template {
      service_account = google_service_account.cloudrun_service_account.email

      containers {
        image   = local.docker_dummy_image_url
        command = ["./scripts/createsuperuser.sh"]

        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = local.project_id
        }

        env {
          name  = "DJANGO_SUPERUSER_USERNAME"
          value = "admin@zosia.org"
        }

        env {
          name  = "DJANGO_SUPERUSER_EMAIL"
          value = "admin@zosia.org"
        }

        env {
          name  = "DJANGO_SUPERUSER_PASSWORD"
          value = ""
        }

        env {
          name  = "DJANGO_SUPERUSER_FIRST_NAME"
          value = "Admin"
        }

        env {
          name  = "DJANGO_SUPERUSER_LAST_NAME"
          value = "Zosiowicz"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].template[0].containers[0].image
    ]
  }
}

resource "google_cloud_run_v2_job" "migrate" {
  name     = "migrate"
  location = local.region

  template {
    template {
      service_account = google_service_account.cloudrun_service_account.email

      containers {
        image   = local.docker_dummy_image_url
        command = ["./scripts/migrate.sh"]

        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = local.project_id
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].template[0].containers[0].image
    ]
  }
}

resource "google_cloud_run_v2_job" "collectstatic" {
  name     = "collectstatic"
  location = local.region

  template {
    template {
      service_account = google_service_account.cloudrun_service_account.email

      containers {
        image   = local.docker_dummy_image_url
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

  lifecycle {
    ignore_changes = [
      template[0].template[0].containers[0].image
    ]
  }
}

resource "google_cloud_run_v2_service" "zosia_site" {
  name     = "zosia"
  location = local.region

  template {
    service_account = google_service_account.cloudrun_service_account.email

    containers {
      image = local.docker_dummy_image_url

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = local.project_id
      }

      env {
        name  = "GCS_BUCKET_NAME"
        value = google_storage_bucket.static_files_bucket.name
      }

      env {
        name  = "HOSTS"
        value = "zosia.org,www.zosia.org"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image
    ]
  }
}

resource "google_cloud_run_domain_mapping" "zosia_domain" {
  name     = "zosia.org"
  location = google_cloud_run_v2_service.zosia_site.location
  metadata {
    namespace = local.project_id
  }
  spec {
    route_name = google_cloud_run_v2_service.zosia_site.name
  }
}

# This allows zosia website to be accessed by anyone without authentication
resource "google_cloud_run_v2_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.zosia_site.location
  name     = google_cloud_run_v2_service.zosia_site.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "static_files_bucket_suffix" {
  byte_length = 8
}

resource "google_storage_bucket" "static_files_bucket" {
  name          = "ksiuwr-zosia-static-files-${random_id.static_files_bucket_suffix.hex}"
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

