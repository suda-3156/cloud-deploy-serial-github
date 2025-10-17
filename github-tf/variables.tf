variable "repository_full_name" {
  type = string
}

variable "wif_project_num" {
  description = "The project number for the Workload Identity Federation project."
  type        = string
}

variable "wif_pool_id" {
  description = "The ID of the Workload Identity Federation pool."
  type        = string
}

variable "wif_provider_id" {
  description = "The ID of the Workload Identity Federation provider."
  type        = string
}

variable "pipeline_project_id" {
  description = "The project ID for the Cloud Deploy pipeline."
  type        = string
}

variable "artifact_registry_repo" {
  description = "The name of the Artifact Registry repository."
  type        = string
}

variable "region" {
  type = string
}
