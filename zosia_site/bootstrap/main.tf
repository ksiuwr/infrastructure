provider "google" {
  project = var.project_id
  region  = var.tfstate_bucket_region
}

resource "random_id" "tfstate_bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "tfstate_bucket" {
  name          = "${random_id.tfstate_bucket_prefix.hex}-tfstate-bucket"
  location      = var.tfstate_bucket_region
  force_destroy = false
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }
}