output "connect-id" {
  value = google_cloudbuildv2_connection.my_connection.id
}
output "repo-id" {
  value = google_cloudbuildv2_repository.my-repository.id
}
