resource "google_app_engine_application" "zosia_site" {
  project     = var.project_id
  location_id = var.region
}

data "google_app_engine_default_service_account" "default" {

  # Read the default service account after its created to avoid errors
  depends_on = [google_app_engine_application.zosia_site]
}

# TODO: Uncomment this (and possibly fix, it's not tested) in production to use the zosia.org domain
# resource "google_app_engine_domain_mapping" "zosia_org_domain" {
#   domain_name = "zosia.org"

#   ssl_settings {
#     ssl_management_type = "AUTOMATIC"
#   }
# }

# resource "google_app_engine_domain_mapping" "www_zosia_org_domain" {
#   domain_name = "www.zosia.org"

#   ssl_settings {
#     ssl_management_type = "AUTOMATIC"
#   }
# }