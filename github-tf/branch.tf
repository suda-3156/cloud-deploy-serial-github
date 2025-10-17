resource "github_branch" "dev" {
  repository = data.github_repository.repo.name
  branch     = "dev"
}

resource "github_branch" "stg" {
  repository = data.github_repository.repo.name
  branch     = "stg"
}

resource "github_branch" "main" {
  repository = data.github_repository.repo.name
  branch     = "main"
}

resource "github_branch_default" "default" {
  repository = data.github_repository.repo.name
  branch     = github_branch.dev.branch
}
