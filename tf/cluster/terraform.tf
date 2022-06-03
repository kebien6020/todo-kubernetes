terraform {
  backend "s3" {
    bucket = "kev-tf-state"
    key    = "todo-kubernetes/state.json"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      project = "todo-kubernetes"
    }
  }
}

provider "random" {
}
