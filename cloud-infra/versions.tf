provider "aws" {
  profile = "terraform-codebase"
  region  = var.general_info.region
}

terraform {
  backend "s3" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.97.0"
    }
  }
  required_version = ">= 1.11.0"
}
