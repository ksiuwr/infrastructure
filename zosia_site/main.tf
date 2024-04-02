module "bootstrap" {
  source                = "./bootstrap"
  tfstate_bucket_region = local.region
  project_id            = local.project_id
}

provider "google" {
  project = local.project_id
  region  = local.region
}
