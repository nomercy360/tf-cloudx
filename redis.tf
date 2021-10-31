resource "google_redis_instance" "cache" {
  name           = "redis"
  tier           = "STANDARD_HA"
  memory_size_gb = 1

  location_id             = "us-central1-a"
  alternative_location_id = "us-central1-f"

  authorized_network = google_compute_network.vpc-network.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  redis_version      = "REDIS_5_0"

  depends_on = [google_service_networking_connection.private_vpc_connection, google_project_service.redis]

}
