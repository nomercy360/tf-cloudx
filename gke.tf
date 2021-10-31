resource "google_container_cluster" "primary" {
  name                     = "cluster"
  location                 = "us-central1"
  subnetwork               = google_compute_subnetwork.subnet.name
  network                  = google_compute_network.vpc-network.name

  remove_default_node_pool = true
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
  }

  initial_node_count = 1
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name           = "my-node-pool"
  location       = "us-central1"
  node_locations = ["us-central1-a", "us-central1-b"]
  cluster        = google_container_cluster.primary.name
  node_count     = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    service_account = google_service_account.kubernetes-sa.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}