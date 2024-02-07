resource "google_secret_manager_secret" "django_settings" {
  secret_id = "django_settings"
  replication {
    auto {}
  }
}

resource "random_password" "django_secret_key" {
  length  = 50
  special = true
}

resource "google_secret_manager_secret_version" "django_settings_version" {
  secret      = google_secret_manager_secret.django_settings.id
  secret_data = <<-EOT
    DB_USERNAME=${var.db_settings["username"]}
    DB_PASSWORD=${random_password.db_password.result}
    DB_HOST=${google_sql_database_instance.db_instance.ip_address.0.ip_address}
    SECRET_KEY=${random_password.django_secret_key.result}
    GAPI_KEY=
    SENTRY_DSN=
    MAILJET_API_KEY=
    MAILJET_SECRET_KEY=
    AWS_ACCESS_KEY_ID=
    AWS_SECRET_ACCESS_KEY=
    CAPTCHA_PUBLIC=
    CAPTCHA_PRIVATE=
    EOT
}

