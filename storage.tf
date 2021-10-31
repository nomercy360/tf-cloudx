resource "google_storage_bucket" "static-site" {
  name          = "${var.project}-nextcloud-external-data"
  location      = "US-CENTRAL1"
  force_destroy = true

  uniform_bucket_level_access = false
}

resource "google_storage_hmac_key" "key" {
  service_account_email = google_service_account.nextcloud-sa.email
}