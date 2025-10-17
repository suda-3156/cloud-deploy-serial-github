# Workload Identity Federation

resource "google_project" "wif" {
  name            = "${var.project_id_prefix}-wif"
  project_id      = "${var.project_id_prefix}-wif"
  folder_id       = var.folder_id
  billing_account = var.billing_account_id

  # TODO
  deletion_policy = "DELETE"
}

resource "time_sleep" "wait_for_wif_project_creation" {
  depends_on      = [google_project.wif]
  create_duration = "60s"
}

# TODO: Quota exceeded なので
# data "google_project" "wif" {
#   project_id = "${var.project_id_prefix}-pipeline"
# }

locals {
  apis_for_wif = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com", # security token service
  ]
}

resource "google_project_service" "wif" {
  for_each = toset(local.apis_for_wif)

  project = google_project.wif.project_id
  service = each.key

  depends_on = [time_sleep.wait_for_wif_project_creation]
}

resource "google_iam_workload_identity_pool" "github" {
  project = google_project.wif.project_id

  workload_identity_pool_id = var.wif_pool_id

  depends_on = [google_project_service.wif]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project = google_project.wif.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id

  display_name = "GitHub Provider"
  disabled     = false

  # TODO
  attribute_condition = <<EOT
    assertion.repository == "suda-3156/cloud-deploy-serial-github"
EOT

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

locals {
  wif_principal = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/suda-3156/cloud-deploy-serial-github"
}

# TODO service accountに対しroleを付与する
# resource "google_project_iam_member" "github-actions-as-wif" {
#   project = google_project.pipeline.project_id
#   role    = "roles/iam.serviceAccountTokenCreator"
#   member  = local.wif_principal
# }

resource "google_service_account_iam_member" "github-actions-as-releaser" {
  service_account_id = google_service_account.releaser.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = local.wif_principal
}

resource "google_service_account_iam_member" "github-actions-as-stg-promoter" {
  service_account_id = google_service_account.stg-promoter.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = local.wif_principal
}

resource "google_service_account_iam_member" "github-actions-as-prod-promoter" {
  service_account_id = google_service_account.prod-promoter.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = local.wif_principal
}
