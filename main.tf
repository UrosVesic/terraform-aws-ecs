terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83.0, < 6.0.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
}

