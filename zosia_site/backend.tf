terraform {
  # Only one `backend "..." {}` block can exist in the configuration file.

  # Uncomment this block to use local storage as your backend.
  #backend "local" {
  #  path = "./terraform.tfstate"
  #}

  # Uncomment this block to use Google Cloud Storage as your backend.
  backend "gcs" {
    bucket = "87d3bb08bfdc3847-tfstate-bucket"
    prefix = "terraform/state"
  }
}
