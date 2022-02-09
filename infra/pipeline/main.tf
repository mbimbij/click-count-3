terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

# Configure the GitHub Provider
provider "github" {
  token = var.PAT
}

data "github_user" "current_user" {
  username = ""
}

resource "github_actions_secret" "AWS_ACCOUNT_ID" {
  repository       = var.REPOSITORY_NAME
  secret_name      = "AWS_ACCOUNT_ID"
  plaintext_value  = var.AWS_ACCOUNT_ID
}

resource "github_actions_secret" "APPLICATION_NAME" {
  repository       = var.REPOSITORY_NAME
  secret_name      = "APPLICATION_NAME"
  plaintext_value  = var.APPLICATION_NAME
}

resource "github_actions_secret" "AWS_REGION" {
  repository       = var.REPOSITORY_NAME
  secret_name      = "AWS_REGION"
  plaintext_value  = var.AWS_REGION
}

resource "github_repository_environment" "production" {
  environment = "production"
  repository  = var.REPOSITORY_NAME
  reviewers {
    users = [data.github_user.current_user.id]
  }
}
