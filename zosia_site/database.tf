resource "google_sql_database" "db" {
  name     = local.db_settings.db_name
  instance = google_sql_database_instance.db_instance.name
}

resource "google_sql_database_instance" "db_instance" {
  name             = local.db_settings.instance_name
  database_version = local.db_settings.database_version

  settings {
    tier      = local.db_settings.database_tier
    edition   = local.db_settings.database_edition
    disk_size = 10

    backup_configuration {
      enabled    = true
      start_time = "02:00"
    }

    ip_configuration {
      ipv4_enabled = true

      # TODO: Currently the production zosia database is configured like this 
      # (no ssl and it accepts connections from every ip)
      # We should discuss if we want to change this
      ssl_mode = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
      authorized_networks {
        value = "0.0.0.0/0"
      }
    }

    maintenance_window {
      day          = 1
      hour         = 3
      update_track = "stable"
    }
  }
  deletion_protection = true
}

resource "google_sql_user" "db_user" {
  name     = local.db_settings.username
  instance = google_sql_database_instance.db_instance.name
  password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length  = 20
  special = true
}
