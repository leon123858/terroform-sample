output "project_id" {
  description = "The ID of the project in which to provision resources."
  value       = "tw-rd-ca-leon-lin"
}
output "location" {
  description = "Name of the location."
  value       = "ASIA"
}
output "region" {
  description = "Name of the region."
  value       = "asia-east1"
}
output "zone" {
  description = "Name of the zone."
  value       = "asia-east1-a"
}
output "git-url" {
  description = "git repo url for code"
  value       = "https://github.com/leon123858/terroform-sample"
}
output "build-file-path" {
  description = "path to container dockerfile ex: docker-sample/Dockerfile"
  value       = "docker-sample/Dockerfile"
}
output "service-name" {
  description = "service name"
  value = "docker-sample"
}