
variable "repo_name" {}

variable "branch_name" {}

variable "source_rev" {}

variable "ecr_repo" {}

variable "aws_region" {
  default = "us-east-1"
}

module "tags" {
  source    = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.4.0"
  name      = "${var.repo_name}-${var.branch_name}"
  namespace = local.namespace
  stage     = local.stage
  tags = {
    repo = var.repo_name
    env  = var.branch_name
    sha  = var.source_rev
  }
}


locals {
  namespace = "rdr"

  stage = "np" //"p"
}
