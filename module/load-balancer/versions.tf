terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.97.0"
    }
  }
  required_version = ">= 1.11.0"
}
