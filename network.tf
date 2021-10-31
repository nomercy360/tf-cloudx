resource "google_compute_network" "vpc-network" {
  name                    = "vpc-network"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute]
}

resource "google_compute_subnetwork" "subnet" {
  name               = "us-central1-subnet"
  ip_cidr_range      = "10.1.0.0/24"
  region             = "us-central1"
  network            = google_compute_network.vpc-network.id
  secondary_ip_range = [
    {
      range_name    = "pods"
      ip_cidr_range = "10.2.0.0/20"
    }, {
      range_name    = "services"
      ip_cidr_range = "10.3.0.0/20"
    }
  ]
}

resource "google_compute_router" "router" {
  name    = "cloud-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc-network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-gateway"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_global_address" "private_ip_address" {
  provider      = google-beta
  project       = var.project
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = google_compute_network.vpc-network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  depends_on              = [google_project_service.networking]
  network                 = google_compute_network.vpc-network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
