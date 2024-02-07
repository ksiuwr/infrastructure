variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "region" {
  description = "The region"
  type        = string
}

variable "db_settings" {
  description = "Map of the various DB Settings"
  type        = map(string)
}