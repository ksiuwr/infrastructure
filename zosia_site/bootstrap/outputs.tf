output "tfstate_bucket_name" {
  description = "The name of the bucket with terraform state"
  value       = google_storage_bucket.tfstate_bucket.name
}