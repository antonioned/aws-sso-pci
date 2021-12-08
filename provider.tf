provider "aws" {
  profile = var.profile
  region  = var.region
}

terraform {
  required_version = "1.0.11"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "apigwstore"
    dynamodb_table = "dyndb-terraform-locks"
    encrypt        = "true"
    key            = "terraform.tfstate"
    profile        = "klinec"
    region         = "eu-west-1"
  }
}
