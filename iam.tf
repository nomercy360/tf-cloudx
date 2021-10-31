resource "google_service_account" "kubernetes-sa" {
  account_id   = "kubernetes-sa"
  display_name = "kubernetes"
  depends_on   = [
    google_project_service.iam,
    google_project_service.container,
    google_project_service.stackdriver,
    google_project_service.sql-admin
  ]
}

resource "google_project_iam_binding" "admin-account-iam" {
  role = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.kubernetes-sa.email}"
  ]
}

resource "google_project_iam_binding" "registry-reader-iam" {
  role = "roles/artifactregistry.reader"

  members = [
    "serviceAccount:${google_service_account.kubernetes-sa.email}"
  ]
}

resource "google_project_iam_binding" "log-writer-iam" {
  role = "roles/logging.logWriter"

  members = [
    "serviceAccount:${google_service_account.kubernetes-sa.email}"
  ]
}
resource "google_project_iam_binding" "metric-writer-iam" {
  role = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.kubernetes-sa.email}"
  ]
}
resource "google_project_iam_binding" "monitoring-viewer-iam" {
  role = "roles/monitoring.viewer"

  members = [
    "serviceAccount:${google_service_account.kubernetes-sa.email}"
  ]
}
resource "google_project_iam_binding" "storage-viewer-iam" {
  role = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_service_account.kubernetes-sa.email}"
  ]
}
resource "google_project_iam_binding" "stackdriver-writer-iam" {
  role = "roles/stackdriver.resourceMetadata.writer"

  members = [
    "serviceAccount:${google_service_account.kubernetes-sa.email}"
  ]
}

resource "google_service_account" "nextcloud-sa" {
  account_id   = "nextcloud-sa"
  display_name = "nextcloud"
  depends_on   = [google_project_service.iam]

}

resource "google_project_iam_binding" "storage-admin-iam" {
  role    = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${google_service_account.nextcloud-sa.email}"
  ]
}