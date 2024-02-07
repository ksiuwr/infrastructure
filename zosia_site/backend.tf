terraform {
  # Only one `backend "..." {}` block can exist in the configuration file.

  # Uncomment this block to use local storage as your backend.
  backend "local" {
    path = "./terraform.tfstate"
  }

  # Uncomment this block to use Google Cloud Storage as your backend.
  # backend "gcs" {
  #   bucket = ""
  #   prefix = "terraform/state"
  # }
}
