terraform {
  # backend "s3" {
  #   bucket         = "given-cingco-devops-directive-tf-state"
  #   key            = "Bitcube-Practical-Test/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-locking"
  #   encrypt        = true
  # }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = "bitcube"
}

