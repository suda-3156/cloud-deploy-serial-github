resource "github_repository_ruleset" "basic_ruleset" {
  repository  = data.github_repository.repo.name
  name        = "Basic Ruleset"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = [
        "refs/heads/dev",
        "refs/heads/stg",
        "refs/heads/main",
      ]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true
  }
}

resource "github_repository_ruleset" "require_pr" {
  repository  = data.github_repository.repo.name
  name        = "Require Pull Request"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = [
        "refs/heads/stg",
        "refs/heads/main",
      ]
      exclude = []
    }
  }

  rules {
    pull_request {
      required_approving_review_count = 0
      dismiss_stale_reviews_on_push   = true
    }
  }
}
