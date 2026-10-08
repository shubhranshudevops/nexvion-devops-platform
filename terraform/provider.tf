provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "NEXVION"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
