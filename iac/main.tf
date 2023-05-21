terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws",
            version = "~> 4.67"
        }
    }

    required_version = ">= 1.0.0"

    backend "s3" {
        bucket = "dcorrea-terraform"
        key = "app-in-php-code-deploy/terraform.tfstate"
        region = "us-east-1"
        shared_credentials_file = "~/.aws/credentials"
        profile = "danilosilva87"
    }
}

provider "aws" {
    region = var.region
    profile = var.profile
}
