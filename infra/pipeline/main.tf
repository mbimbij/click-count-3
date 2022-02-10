terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "github" {
  token = var.PAT
}

resource "github_actions_secret" "AWS_ACCOUNT_ID" {
  repository      = data.github_repository.repository.name
  secret_name     = "AWS_ACCOUNT_ID"
  plaintext_value = var.AWS_ACCOUNT_ID
}

resource "github_actions_secret" "APPLICATION_NAME" {
  repository      = var.REPOSITORY_NAME
  secret_name     = "APPLICATION_NAME"
  plaintext_value = var.APPLICATION_NAME
}

resource "github_actions_secret" "AWS_REGION" {
  repository      = var.REPOSITORY_NAME
  secret_name     = "AWS_REGION"
  plaintext_value = var.AWS_REGION
}

resource "github_repository_environment" "staging" {
  environment = "staging"
  repository  = var.REPOSITORY_NAME
}

resource "github_actions_environment_secret" "redis_staging" {
  environment     = "staging"
  secret_name     = "redis_host"
  plaintext_value = data.aws_ssm_parameter.redis_host_staging.value
  repository      = data.github_repository.repository.name
}

resource "github_repository_environment" "production" {
  environment = "production"
  repository  = var.REPOSITORY_NAME
  reviewers {
    users = [data.github_user.current_user.id]
  }
}

resource "github_actions_environment_secret" "redis_production" {
  environment     = "production"
  secret_name     = "redis_host"
  plaintext_value = data.aws_ssm_parameter.redis_host_production.value
  repository      = data.github_repository.repository.name
}
