locals {
  project_id = ""
  region     = "europe-central2"

  db_settings = {
    username         = "zosia-admin"
    instance_name    = "zosia-db"
    db_name          = "zosia"
    database_tier    = "db-f1-micro"
    database_edition = "ENTERPRISE"
    database_version = "POSTGRES_15"
  }
}
