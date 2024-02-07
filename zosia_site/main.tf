module "bootstrap" {
  source                = "./bootstrap"
  tfstate_bucket_region = var.region
  project_id            = var.project_id
}

provider "google" {
  project = var.project_id
  region  = var.region
}