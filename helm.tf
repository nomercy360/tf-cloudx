data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

resource "helm_release" "ingress" {
  name       = "nginx-ingress"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  version    = "9.0.2"
  set {
    name  = "config.proxy-body-size"
    value = "100m"
  }
  depends_on = [google_container_cluster.primary, google_container_node_pool.primary_nodes]
}

resource "kubernetes_secret" "mysql-credentials" {
  metadata {
    name = "nextcloud-mysql"
  }

  data = {
    username = "nextcloud"
    password = var.mysql-password
  }

}

resource "kubernetes_secret" "nextcloud-credentials" {
  metadata {
    name = "nextcloud-admin"
  }

  data = {
    username = "nextcloud"
    password = "nextcloud"
  }
}


resource "helm_release" "nextcloud" {
  name       = "nextcloud"
  chart      = "nextcloud/nextcloud-2.9.0.tgz"
  depends_on = [null_resource.run_build, google_container_cluster.primary, google_container_node_pool.primary_nodes]
  version    = "2.9.0"
  values     = [
    templatefile("nextcloud/values.tpl", {
      mysql_ip_address = google_sql_database_instance.instance.private_ip_address
      gcp_project      = var.project
      redis_ip_address = google_redis_instance.cache.host
      storage_key      = google_storage_hmac_key.key.access_id
      storage_secret   = google_storage_hmac_key.key.secret
    })
  ]
}