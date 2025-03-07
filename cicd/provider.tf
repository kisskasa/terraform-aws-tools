terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.81.0"
    }
  }
  backend "s3" {
    bucket = "chandrakasa-remote-state"
    key    = "jenkins" # key should be unique for every project
    region = "us-east-1"
    dynamodb_table = "chandrakasa-locking"
  }
}

# provide authentication here
provider "aws" {
  region = "us-east-1"
}