data "github_user" "current_user" {
  username = ""
}

data "aws_ssm_parameter" "redis_host_staging" {
  name = "/${var.APPLICATION_NAME}/staging/redis/address"
}

data "aws_ssm_parameter" "redis_host_production" {
  name = "/${var.APPLICATION_NAME}/production/redis/address"
}

data "github_repository" "repository" {
  name = var.REPOSITORY_NAME
}
