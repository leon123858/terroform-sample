/*
這個檔案包含 Terraform 模組所建立的 GKE 叢集和 VPC 的輸出值。
*/

output "vpc_name" {
  value = google_compute_network.vpc-network.name
}

output "gke_cluster_name" {
  value = google_container_cluster.primary.name
}

output "gke_subnetwork_name" {
  value = google_compute_subnetwork.vpc-subnet.name
}
