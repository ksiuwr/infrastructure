output "tfstate_bucket_name" {
  description = "The name of the bucket with terraform state"
  value       = module.bootstrap.tfstate_bucket_name
}