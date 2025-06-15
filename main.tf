terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83.0, < 6.0.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-bucket-288761758415"
    key            = "social-network/terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region  = "eu-central-1"
}

