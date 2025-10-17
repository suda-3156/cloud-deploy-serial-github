resource "github_actions_secret" "wif_project_num" {
  repository      = data.github_repository.repo.name
  secret_name     = "WIF_PROJECT_NUM"
  plaintext_value = var.wif_project_num
}

resource "github_actions_secret" "wif_pool_id" {
  repository      = data.github_repository.repo.name
  secret_name     = "WIF_POOL_ID"
  plaintext_value = var.wif_pool_id
}

resource "github_actions_secret" "wif_provider_id" {
  repository      = data.github_repository.repo.name
  secret_name     = "WIF_PROVIDER_ID"
  plaintext_value = var.wif_provider_id
}

resource "github_actions_secret" "pipeline_project_id" {
  repository      = data.github_repository.repo.name
  secret_name     = "PIPELINE_PROJECT_ID"
  plaintext_value = var.pipeline_project_id
}

resource "github_actions_secret" "artifact_registry_repo" {
  repository      = data.github_repository.repo.name
  secret_name     = "ARTIFACT_REGISTRY_REPO"
  plaintext_value = var.artifact_registry_repo
}

resource "github_actions_secret" "region" {
  repository      = data.github_repository.repo.name
  secret_name     = "GCP_REGION"
  plaintext_value = var.region
}
