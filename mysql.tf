resource "random_id" "db_name_suffix" {
  byte_length = 4
}
resource "google_sql_database_instance" "instance" {
  provider = google-beta

  name                = "database-${random_id.db_name_suffix.hex}"
  region              = "us-central1"
  project             = var.project
  depends_on          = [google_service_networking_connection.private_vpc_connection]
  database_version    = "MYSQL_8_0"
  deletion_protection = false

  settings {

    availability_type = "REGIONAL"
    tier              = "db-n1-standard-1"
    disk_size         = 10
    disk_autoresize   = true
    disk_type         = "PD_SSD"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc-network.id
    }

    maintenance_window {
      day  = 6
      hour = 0
    }

    backup_configuration {
      binary_log_enabled = true
      enabled            = true
      location           = "US"
      start_time         = "01:00"
      backup_retention_settings {
        retained_backups = 30
      }
    }
  }
}

resource "google_sql_database" "database" {
  name      = "nextcloud"
  charset   = "utf8mb4"
  collation = "utf8mb4_general_ci"
  instance  = google_sql_database_instance.instance.name
}

resource "google_sql_user" "users" {
  name     = "nextcloud"
  instance = google_sql_database_instance.instance.name
  password = var.mysql-password
}

provider "google-beta" {
  region = "us-central1"
  zone   = "us-central1-a"
}