provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

terraform {
  backend "s3" {
    bucket         = "altered-terraform"
    dynamodb_table = "altered-terraform"
    region         = "us-east-1"
  }
}
