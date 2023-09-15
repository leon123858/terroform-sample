output "name" {
  value       = google_storage_bucket.firestore-backup-bucket.name
  description = "The name of the bucket"
}
output "path" {
  value       = google_storage_bucket.firestore-backup-bucket.url
  description = "The link of the bucket"
}
