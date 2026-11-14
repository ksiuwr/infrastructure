locals {
  project_id = "leosia26"
  region     = "europe-west4"

  # One Cloud Run service serves both ZOSIA and LEOSIA, the app picks the site by domain.
  # Every domain listed here gets a domain mapping. To host only one site, remove the
  # other site's domains - its database stays, but nothing will reach it.
  domains = [
    "zosia.org",
    "www.zosia.org",
    "leosia.org",
    "www.leosia.org",
  ]

  db_settings = {
    username         = "zosia-admin"
    instance_name    = "zosia-db"
    db_name          = "zosia"
    leosia_db_name   = "leosia" # Both names must match SITES in the app settings
    database_tier    = "db-f1-micro"
    database_edition = "ENTERPRISE"
    database_version = "POSTGRES_15"
  }
}
