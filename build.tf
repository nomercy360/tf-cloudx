resource "null_resource" "run_build" {
  depends_on = [google_project_service.build]
  provisioner "local-exec" {
    command = "cd nextcloud && gcloud builds submit --tag=gcr.io/${var.project}/nextcloud:21.0.1-apache ."
  }
}